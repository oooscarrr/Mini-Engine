service_exists=$(kubectl get svc kafka-broker-0-external --ignore-not-found)

if [ -z "$service_exists" ]; then
  # If the service does not exist, we are at plan stage, exit with a message
  echo "Service kafka-broker-0-external has not been created. Exiting as this is likely the plan stage." >&2
  echo {}
  exit 0
fi

# If the service exists, proceed to wait for the IP ready
echo "Service kafka-broker-0-external has been created. Checking for external IP..." >&2

# Wait until the IP address is available
while true; do
  ip=$(kubectl get svc kafka-broker-0-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [ -n "$ip" ]; then
    # IP is available, output it in JSON format
    echo "{\"ip\": \"$ip\"}"
    break
  else
    # Wait and retry
    echo "Waiting for kafka-broker-0-external external IP to become available..." >&2
    sleep 5
  fi
done