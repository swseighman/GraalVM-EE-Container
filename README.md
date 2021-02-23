## Creating a GraalVM Enterprise Edition Container Image### Overview
As you continue to explore the many features and benefits of GraalVM Enterprise Edition, you'll likely need a reproducible build environment (with few dependencies) to assist with your testing.  Having a self-contained build process will streamline your development pipeline and help you easily produce native image executables that can be deployed in your container/Kubernetes environment. This tutorial highlights the steps to create a GraalVM Enterprise Edition image which you can leverage for your multi-stage image builds.

**Note**: Throughout this tutorial, when you see a ![red computer](images/userinput.png) icon, it indicates a command that you'll need to enter in your terminal. ### CreditsThe contents of this tutorial is based on a video originally recorded by **Oleg Šelajev**. See [this link](https://www.youtube.com/watch?v=kDpBffInt_Y&list=PLirn7Sv6CJgGEBn0dVaaNojhi_4T3l2PF&index=3).

### Let's get started!We'll begin with an Oracle Linux 8 (Slim) base image to serve as the foundation for our GraalVM builder image:

![user input](images/userinput.png)
```$ docker run -it oraclelinux:8-slim bash
```
Inside the base image, install the libraries and utilities we'll need to complete the GraalVM installation:

![user input](images/userinput.png)
```
# microdnf --enablerepo ol8_codeready_builder install bzip2-devel ed gcc gcc-c++ gcc-gfortran gzip file fontconfig less libcurl-devel make openssl openssl-devel readline-devel tar vi which xz-devel zlib-devel findutils glibc-static libstdc++ libstdc++-devel libstdc++-static zlib-static
```
Next, download the GraalVM Community Edition tar file:

![user input](images/userinput.png)

For Java 11:

```# curl -L -o graalvm-ce-java11-linux-amd64-21.0.0.tar.gz https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.0.0/graalvm-ce-java11-linux-amd64-21.0.0.tar.gz
```
*Or for Java 8:*

```
# curl -L -o graalvm-ce-java8-linux-amd64-21.0.0.tar.gz https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.0.0/graalvm-ce-java8-linux-amd64-21.0.0.tar.gz
```

Unzip the `tar` file:

![user input](images/userinput.png)

```# tar -xzf graalvm-ce-java11-linux-amd64-21.0.0.tar.gz
```
Since our goal is to install GraalVM Enterprise Edition, we'll perform an in-place upgrade (new in GraalVM 21).  You'll need to answer `Y` to the license agreement and you'll also be prompted to enter your emaill address.

![user input](images/userinput.png)
```# /graalvm-ce-java11-21.0.0/bin/gu upgrade --edition eeDownloading: Release index file from oca.opensource.oracle.comDownloading: Component catalog for GraalVM Enterprise Edition 21.0.0 on jdk11 from oca.opensource.oracle.comDownloading: Component catalog for GraalVM Enterprise Edition 21.0.0 on jdk11 from oca.opensource.oracle.com=========================================================================        Preparing to install GraalVM Core version 21.0.0.        Destination directory: /graalvm-ee-java11-21.0.0=========================================================================The component(s) GraalVM Core requires to accept the following license: GraalVM Enterprise Edition LicenseEnter "Y" to confirm and accept all the license(s). Enter "R" to the see license text.Any other input will abort installation:  YDownloading: Contents of "GraalVM Enterprise Edition License" from oca.opensource.oracle.comPlease provide an email address (optional). You may want to check Oracle Privacy Policy (https://www.oracle.com/legal/privacy/privacy-policy.html).Enter a valid e-mail address: scott.seighman@oracle.comDownloading: Component core: GraalVM Core  from oca.opensource.oracle.comDownloading: Component org.graalvm: GraalVM Core  from oca.opensource.oracle.comInstalling GraalVM Core version 21.0.0 to /graalvm-ee-java11-21.0.0...```
Let's set some environment variables to streamline the reamining GraalVM installation tasks.

![user input](images/userinput.png)

```# export GRAALVM_HOME=/graalvm-ee-java11-21.0.0
# export JAVA_HOME=$GRAALVM_HOME# export PATH=$GRAALVM_HOME/bin:$PATH# java -versionjava version "11.0.10" 2021-01-19 LTSJava(TM) SE Runtime Environment GraalVM EE 21.0.0 (build 11.0.10+8-LTS-jvmci-21.0-b06)Java HotSpot(TM) 64-Bit Server VM GraalVM EE 21.0.0 (build 11.0.10+8-LTS-jvmci-21.0-b06, mixed mode, sharing)```
Install the `native-image` module.  Once again, you'll need to agree to the license terms and enter your email.

![user input](images/userinput.png)

```# gu install native-imageDownloading: Release index file from oca.opensource.oracle.comDownloading: Component catalog for GraalVM Enterprise Edition 21.0.0 on jdk11 from oca.opensource.oracle.comDownloading: Component catalog for GraalVM Enterprise Edition 21.0.0 on jdk11 from oca.opensource.oracle.comSkipping ULN EE channels, no username provided.Downloading: Component catalog from www.graalvm.orgProcessing Component: Native ImageThe component(s) Native Image requires to accept the following license: Oracle GraalVM Enterprise Edition Native Image LicenseEnter "Y" to confirm and accept all the license(s). Enter "R" to the see license text.Any other input will abort installation:  YDownloading: Contents of "Oracle GraalVM Enterprise Edition Native Image License" from oca.opensource.oracle.comPlease provide an email address (optional). You may want to check Oracle Privacy Policy (https://www.oracle.com/legal/privacy/privacy-policy.html).Enter a valid e-mail address: scott.seighman@oracle.comDownloading: Component native-image: Native Image  from oca.opensource.oracle.comInstalling new component: Native Image (org.graalvm.native-image, version 21.0.0)```
In addition, install the `Python` module to round out a (fairly) complete GraalVM image.  LLVM will also be installed as a dependency by default.

![user input](images/userinput.png)

```# gu install pythonDownloading: Release index file from oca.opensource.oracle.comDownloading: Component catalog for GraalVM Enterprise Edition 21.0.0 on jdk11 from oca.opensource.oracle.comDownloading: Component catalog for GraalVM Enterprise Edition 21.0.0 on jdk11 from oca.opensource.oracle.comSkipping ULN EE channels, no username provided.Downloading: Component catalog from www.graalvm.orgProcessing Component: Graal.Python EEProcessing Component: LLVM.org toolchainAdditional Components are required:    LLVM.org toolchain (org.graalvm.llvm-toolchain, version 21.0.0), required by: Graal.Python EE (org.graalvm.python)The component(s) Graal.Python EE, LLVM.org toolchain requires to accept the following license: GraalVM Enterprise Edition LicenseEnter "Y" to confirm and accept all the license(s). Enter "R" to the see license text.Any other input will abort installation: YDownloading: Contents of "GraalVM Enterprise Edition License" from oca.opensource.oracle.comDownloading: Component python: Graal.Python EE  from oca.opensource.oracle.comDownloading: Component org.graalvm.llvm-toolchain: LLVM.org toolchain  from oca.opensource.oracle.comInstalling new component: LLVM.org toolchain (org.graalvm.llvm-toolchain, version 21.0.0)Installing new component: Graal.Python EE (org.graalvm.python, version 21.0.0)IMPORTANT NOTE:---------------Set of GraalVM components that provide language implementations have changed. The Polyglot native image and polyglot native C library may be out of sync:- new languages may not be accessible- removed languages may cause the native binary to fail on missing resources or libraries.To rebuild and refresh the native binaries, use the following command:        /graalvm-ee-java11-21.0.0/bin/gu rebuild-images```
Check to make certain the modules installed properly.

![user input](images/userinput.png)

```# gu listComponentId     Version    Component name       Stability           Origin-----------------------------------------------------------------------------js              21.0.0.2   Graal.js              -graalvm         21.0.0.2   GraalVM Core          -llvm-toolchain  21.0.0.2   LLVM.org toolchain    Supported 	oca.opensource.oracle.comnative-image    21.0.0.2   Native Image          Early adopter       oca.opensource.oracle.compython          21.0.0.2   Graal.Python EE       Experimental        oca.opensource.oracle.com```

![user input](images/userinput.png)

Install Maven.

```
# curl -L -o apache-maven-3.6.3-bin.tar.gz https://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
# tar -xzf apache-maven-3.6.3-bin.tar.gz
```
Remove the original GraalVM Community Edition directory and the GraalVM and Maven`tar` files. Clean up any remaining package installation files.

Exit the image.

![user input](images/userinput.png)

```# rm -rf graalvm-ce-java11-21.0.0/# rm graalvm-ce-java11-linux-amd64-21.0.0.tar.gz
# rm apache-maven-3.6.3-bin.tar.gz
# microdnf clean all# exit```
Once we're satisfied with the our base image, we'll commit the changes to our new GraalVM image.  First, identify the container ID from `oraclelinux:8-slim`, then execute the commit using that container ID.

![user input](images/userinput.png)

```$ docker ps -a
CONTAINER ID   IMAGE    	       COMMAND    CREATED          STATUS.         PORTS     NAMES5b3a9f76ef02   oraclelinux:8-slim  "bash"    10 minutes ago    Exited (0) 6 seconds ago
```
```$ docker commit 5b3a9f76ef02 graalvm-11-ee:v1
sha256:c98998185c4b499db2bb881dc5c83c55dda4227f89286064d9329f8cb16c9633
```
That's it!  You now have a GraalVM Enterprise Edition image you can use to build native image executables or any other GraalVM tasks.

![user input](images/userinput.png)

```$ docker imagesREPOSITORY            TAG         IMAGE ID       CREATED              SIZEgraalvm-11-ee         v1          4552add89a43   About a minute ago   2.11GB```
One option you may want to consider is configuring the PATH of your GraalVM image to include both the `java` and `mvn` bin directories.

Using the image ID from the newly created image, check the current PATH included with the image.  The current path of the image will be displayed.


![user input](images/userinput.png)

```$ docker inspect -f "{{ .Config.Env }}" 4552add89a43[PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin]```
Next, note the container ID of the new image.

![user input](images/userinput.png)

```$ docker ps -aCONTAINER ID   IMAGE         COMMAND     CREATED     STATUS      PORTS     NAMESc78fc9abb86c   48060023630c  "/graalvm-ee-java11-…"  20 minutes ago      Exited (0) 20 minutes```
Add or append the `java` and `mvn` paths to the existing `PATH` in the image and commit the changes (which will create a new image). Be certain to update the tag (v2 in this example).

![user input](images/userinput.png)

```$ docker commit --change "ENV PATH=/graalvm-ee-java11-21.0.0/bin:/apache-maven-3.6.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin JAVA_HOME=/graalvm-ee-java11-21.0.0" c78fc9abb86c graalvm-11-ee:v2```

![user input](images/userinput.png)
```$ docker imagesREPOSITORY            TAG         IMAGE ID       CREATED              SIZEgraalvm-11-ee         v2          d94c75a9582d   About a minute ago   2.11GBgraalvm-11-ee         v1          4552add89a43   5 minutes ago        2.11GB```
Check the PATH of the newly committed image using the (v2) image ID.

![user input](images/userinput.png)

```$ docker inspect -f "{{ .Config.Env }}" d94c75a9582d[PATH=/graalvm-ee-java11-21.0.0/bin:/apache-maven-3.6.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin]```
You can test the PATH by executing a `java` command inside the container.

![user input](images/userinput.png)

```$ docker run graalvm-11-ee:v2 java -XshowSettings:vm -versionVM settings:    Max. Heap Size (Estimated): 6.26G    Using VM: Java HotSpot(TM) 64-Bit Server VMjava version "11.0.10" 2021-01-19 LTSJava(TM) SE Runtime Environment GraalVM EE 21.0.0.2 (build 11.0.10+8-LTS-jvmci-21.0-b06)Java HotSpot(TM) 64-Bit Server VM GraalVM EE 21.0.0.2 (build 11.0.10+8-LTS-jvmci-21.0-b06, mixed mode, sharing)```

### Let's test a simple native image build

To make certain our GraalVM Enterprise Edition builder images works as expected, we'll compile a simple application, create a native image executable and deploy the demo application to a container.

First, clone the demo repository and change to the `src` directory:

![user input](images/userinput.png)

```
$ git clone https://github.com/swseighman/GraalVM-EE-Container.git
```
```
$ cd src
```

Next, run the application and container build script:

![user input](images/userinput.png)

```
$ ./container-build.sh
[+] Building 36.4s (10/10) FINISHED
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 436B                                                                               0.0s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 2B                                                                                    0.0s
 => [internal] load metadata for docker.io/library/graalvm-11-ee:v2                                                0.0s
 => [internal] load build context                                                                                  0.4s
 => => transferring context: 25.28MB                                                                               0.4s
 => CACHED [graalvm 1/4] FROM docker.io/library/graalvm-11-ee:v2                                                   0.0s
 => [graalvm 2/4] COPY . /home/app/graalvm-demo                                                                    0.1s
 => [graalvm 3/4] WORKDIR /home/app/graalvm-demo                                                                   0.0s
 => [graalvm 4/4] RUN javac Main.java     && jar --create --file=graalvm-demo.jar --main-class=Main  Main.class   35.7s
 => [stage-1 1/1] COPY --from=graalvm /home/app/graalvm-demo/graalvm-demo graalvm-demo                             0.0s
 => exporting to image                                                                                             0.1s
 => => exporting layers                                                                                            0.0s
 => => writing image sha256:5e61e56dec6dbfc539688e4c5f6902f27a6a2df8453d5de4d7c491064edf6406                       0.0s
 => => naming to docker.io/library/graalvm-demo
```
![user input](images/userinput.png)

```
$ docker images
REPOSITORY             TAG          IMAGE ID         CREATED            SIZE
graalvm-demo           latest       5e61e56dec6d     16 minutes ago     11MB
```
![user input](images/userinput.png)

```
$ docker run graalvm-demo:latest
Hello from GraalVM!
```

### Summary

Congratulations! You successfully completed the process of creating a GraalVM Enterprise Edition builder image you can use for any future application builds.  Plus, you were able to deploy a demo application utilizing the builder image. Feel free to test more complex application builds!