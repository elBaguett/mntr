for pod in smtp-test smtp-76cc59b7cf-9cf7b; do
  echo "===== $pod /etc/postfix ====="
  sudo kubectl exec -n mntr $pod -- ls -l /etc/postfix
  echo "===== $pod /etc/postfix/sasl ====="
  sudo kubectl exec -n mntr $pod -- ls -l /etc/postfix/sasl
  echo "===== $pod main.cf ====="
  sudo kubectl exec -n mntr $pod -- cat /etc/postfix/main.cf
  echo "===== $pod master.cf ====="
  sudo kubectl exec -n mntr $pod -- cat /etc/postfix/master.cf
  echo "===== $pod /etc/aliases ====="
  sudo kubectl exec -n mntr $pod -- cat /etc/aliases
done