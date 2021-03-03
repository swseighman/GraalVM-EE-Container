docker build . -t graalvm-demo
# For distroless, uncomment the follwing line and comment the line above
docker build -f Dockerfile.ditroless -t graalvm-demo
echo
echo
echo " To run the demo container, execute:"
echo " $ docker run graalvm-demo"
echo 
