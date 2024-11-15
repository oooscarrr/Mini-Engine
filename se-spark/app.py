from pyspark.sql import SparkSession, functions as F
from pyspark.sql.functions import collect_list, explode, udf, col, from_json, struct, to_json, sum as _sum
from pyspark.sql.types import StructType, StructField, StringType, ArrayType
import re
import nltk
from nltk.corpus import stopwords
import os
from dotenv import load_dotenv

bootstrap_servers = os.getenv("KAFKA_IP")+":9094"
# bootstrap_servers = "localhost:9092"

spark = SparkSession.builder \
    .appName("KafkaInvertedIndex") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0") \
    .config("spark.sql.streaming.statefulOperator.checkCorrectness.enabled", "false") \
    .config("spark.kafka.consumer.fetch.message.max.bytes", "104857600") \
    .config("spark.kafka.consumer.max.partition.fetch.bytes", "104857600") \
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")

nltk.download('stopwords')
stop_words = set(stopwords.words('english'))

schema = StructType([
    StructField("folder", StringType(), True),
    StructField("name", StringType(), True),
    StructField("content", StringType(), True)
])

kafka_df = (
    spark.readStream
    .format("kafka")
    .option("kafka.bootstrap.servers", bootstrap_servers)
    .option("subscribe", "project-topic")
    .option("failOnDataLoss", "false")
    .load()
)

parsed_df = kafka_df.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.folder", "data.name", "data.content")

def clean_and_split_text(content):
    text = re.sub(r"[\n\r\t]", " ", content)
    text = re.sub(r"\s+", " ", text)
    words = re.findall(r"\b[a-zA-Z]+\b", text.lower())
    # Filter out NLTK stop words
    return [word for word in words if word not in stop_words]


clean_and_split_text_udf = udf(clean_and_split_text, ArrayType(StringType()))
parsed_df = parsed_df.withColumn("words", clean_and_split_text_udf(col("content")))
words_df = parsed_df.select("folder", "name", explode("words").alias("word"))


inverted_index_df = (
    words_df.groupBy("word", "folder", "name")
    .count()
    .groupBy("word")
    .agg(collect_list(struct("folder", "name", "count")).alias("documents"))
)

word_counts_df = words_df.groupBy("word", "folder", "name").count()
word_frequency_df = (
    word_counts_df.groupBy("word")
    .agg(_sum("count").alias("total_frequency"))
)

inverted_index_output_df = inverted_index_df.select(
    col("word").alias("key"), 
    to_json(struct("documents")).alias("value")
)

inverted_index_query = (
    inverted_index_output_df.writeStream
    .format("kafka")
    .option("kafka.bootstrap.servers", bootstrap_servers)
    .option("topic", "inverted-index-topic")
    .option("checkpointLocation", "/tmp/spark-temp-checkpoints")
    .option("failOnDataLoss", "false")
    .outputMode("complete")
    .start()
)

top_n_words = word_frequency_df.orderBy(col("total_frequency").desc())

top_n_output_df = top_n_words.select(
    F.col("word").alias("key"), 
    F.to_json(F.struct("total_frequency")).alias("value")
)

top_n_query = (
    top_n_output_df.writeStream
    .format("kafka")
    .option("kafka.bootstrap.servers", bootstrap_servers) 
    .option("topic", "top-n-topic")
    .option("checkpointLocation", "/tmp/spark-top-n-checkpoints")
    .option("failOnDataLoss", "false")
    .outputMode("complete")
    .start()
)

top_n_query.awaitTermination()
inverted_index_query.awaitTermination()