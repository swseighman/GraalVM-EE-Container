FROM graalvm-11-ee:v2 as graalvm

COPY . /home/app/graalvm-demo
WORKDIR /home/app/graalvm-demo

RUN javac Main.java \
    && jar --create --file=graalvm-demo.jar --main-class=Main  Main.class \
    && native-image --static -H:Class=Main -H:Name=graalvm-demo -jar graalvm-demo.jar

FROM scratch

COPY --from=graalvm /home/app/graalvm-demo/graalvm-demo graalvm-demo
ENTRYPOINT ["/graalvm-demo"]