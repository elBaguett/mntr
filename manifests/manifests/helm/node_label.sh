kubectl patch node  -p '{"spec":{"providerID":"aws:///<AZ>/<instance-id>"}}'

kubectl patch node ip-10-10-10-11 -p '{"spec":{"providerID":"aws:///us-east-1/i-0619594fa16c21bdf"}}'
kubectl patch node ip-10-10-20-11 -p '{"spec":{"providerID":"aws:///us-east-1/i-0e64243f74ac1e067"}}'
kubectl patch node ip-10-10-20-14 -p '{"spec":{"providerID":"aws:///us-east-1/i-0c0349c4d3d8a54af"}}'
kubectl patch node ip-10-20-10-10 -p '{"spec":{"providerID":"aws:///eu-west-1/i-05e40656c00bf247f"}}'
kubectl patch node ip-10-20-20-10 -p '{"spec":{"providerID":"aws:///eu-west-1/i-0b0bb837a384315af"}}'
kubectl patch node ip-10-20-20-12 -p '{"spec":{"providerID":"aws:///eu-west-1/i-0b2d4fa0540a04e2b"}}'
