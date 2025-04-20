while true; do
    clear
    echo "=== Raspberry Pi Status Screen ==="
    echo
    echo "Memory Usage:"
    free -h
    echo
    echo "Temperature:"
    vcgencmd measure_temp
    echo
    echo "Top Processes:"
    ps aux --sort=-%cpu | head -n 4
    echo
    echo "Docker Containers:"
    docker ps
    sleep 5
done