# Use an appropriate base image
FROM alpine:latest

# Install necessary packages
RUN apk update && apk add --no-cache bash

# Copy the entrypoint script into the container
COPY init.sh entrypoint.sh setup_xmrig.sh /root/

# Make the entrypoint script executable
RUN chmod +x /root/entrypoint.sh
RUN chmod +x /root/setup_xmrig.sh
RUN chmod +x /root/init.sh
# Set the entrypoint to the bash script
ENTRYPOINT ["/root/init.sh"]

# Optionally set a default command, if necessary
CMD ["bash"]
