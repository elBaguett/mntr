#!/bin/bash

MANIFESTS_DIR="/etc/kubernetes/manifests"

new_initialDelay=60
new_period=10
new_timeout=60
new_failure=12

new_startupDelay=60
new_startupTimeout=30
new_startupPeriod=10
new_startupFailure=36

for file in $MANIFESTS_DIR/*.yaml; do
    echo "Patch $file"
    # livenessProbe
    sed -i -r \
      -e "/livenessProbe:/,/- [a-zA-Z]/ {
          s/(initialDelaySeconds:).*/\1 $new_initialDelay/;
          s/(timeoutSeconds:).*/\1 $new_timeout/;
          s/(periodSeconds:).*/\1 $new_period/;
          s/(failureThreshold:).*/\1 $new_failure/;
      }" \
      "$file"
    sed -i -r \
      -e "/readinessProbe:/,/- [a-zA-Z]/ {
          s/(initialDelaySeconds:).*/\1 $new_initialDelay/;
          s/(timeoutSeconds:).*/\1 $new_timeout/;
          s/(periodSeconds:).*/\1 $new_period/;
          s/(failureThreshold:).*/\1 $new_failure/;
      }" \
      "$file"
    sed -i -r \
      -e "/startupProbe:/,/- [a-zA-Z]/ {
          s/(initialDelaySeconds:).*/\1 $new_startupDelay/;
          s/(timeoutSeconds:).*/\1 $new_startupTimeout/;
          s/(periodSeconds:).*/\1 $new_startupPeriod/;
          s/(failureThreshold:).*/\1 $new_startupFailure/;
      }" \
      "$file"
done

echo "All manifests are updated, kubelet will restart"
