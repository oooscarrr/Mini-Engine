FROM python:3.9-slim-buster
WORKDIR /app
COPY ./requirements.txt /app
RUN pip3 install -r requirements.txt
COPY . .

ENV KAFKA_OPTS="$KAFKA_OPTS -XX:ReservedCodeCacheSize=256m"

EXPOSE 5001

ENTRYPOINT ["python3"]
CMD ["app.py"]
