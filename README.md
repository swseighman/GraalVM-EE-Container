## Creating a GraalVM Enterprise Edition Container Image
As you continue to explore the many features and benefits of GraalVM Enterprise Edition, you'll likely need a reproducible build environment (with few dependencies) to assist with your testing.  Having a self-contained build process will streamline your development pipeline and help you easily produce native image executables that can be deployed in your container/Kubernetes environment. This tutorial highlights the steps to create a GraalVM Enterprise Edition image which you can leverage for your multi-stage image builds.

**Note**: Throughout this tutorial, when you see a ![red computer](images/userinput.png) icon, it indicates a command that you'll need to enter in your terminal. 

### Let's get started!

![user input](images/userinput.png)

```
Inside the base image, install the libraries and utilities we'll need to complete the GraalVM installation:

![user input](images/userinput.png)

# microdnf install tar find gzip gcc glibc-devel zlib-devel
```
Next, download the GraalVM Community Edition tar file:

![user input](images/userinput.png)

For Java 11:

```
```
*Or for Java 8:*

```
# curl -L -o graalvm-ce-java8-linux-amd64-21.0.0.2.tar.gz https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.0.0.2/graalvm-ce-java8-linux-amd64-21.0.0.2.tar.gz
```

Unzip the `tar` file:

![user input](images/userinput.png)

```
```
Since our goal is to install GraalVM Enterprise Edition, we'll perform an in-place upgrade (new in GraalVM 21).  You'll need to answer `Y` to the license agreement and you'll also be prompted to enter your emaill address.

![user input](images/userinput.png)

Let's set some environment variables to streamline the reamining GraalVM installation tasks.

![user input](images/userinput.png)

```
# export JAVA_HOME=$GRAALVM_HOME
Install the `native-image` module.  Once again, you'll need to agree to the license terms and enter your email.

![user input](images/userinput.png)

```
In addition, install the `Python` module to round out a (fairly) complete GraalVM image.  LLVM will also be installed as a dependency by default.

![user input](images/userinput.png)

```
Check to make certain the modules installed properly.

![user input](images/userinput.png)

```

![user input](images/userinput.png)

Install Maven.

```
# curl -L -o apache-maven-3.6.3-bin.tar.gz https://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
# tar -xzf apache-maven-3.6.3-bin.tar.gz
```
Remove the original GraalVM Community Edition directory and the GraalVM and Maven`tar` files. Clean up any remaining package installation files.

Exit the image.

![user input](images/userinput.png)

```
# rm apache-maven-3.6.3-bin.tar.gz
# microdnf clean all
Once we're satisfied with the our base image, we'll commit the changes to our new GraalVM image.  First, identify the container ID from `oraclelinux:8-slim`, then execute the commit using that container ID.

![user input](images/userinput.png)

```
CONTAINER ID   IMAGE    	       COMMAND    CREATED          STATUS.         PORTS     NAMES
```
```
sha256:c98998185c4b499db2bb881dc5c83c55dda4227f89286064d9329f8cb16c9633
```
That's it!  You now have a GraalVM Enterprise Edition image you can use to build native image executables or any other GraalVM tasks.

![user input](images/userinput.png)

```
One option you may want to consider is configuring the PATH of your GraalVM image to include the `java bin` directory.

Using the image ID from the newly created image, check the current PATH included with the image.  The current path of the image will be displayed.


![user input](images/userinput.png)

```
Next, note the container ID of the new image.

![user input](images/userinput.png)

```
Add or append the `java` path to the existing `PATH` in the image and commit the changes (which will create a new image). Be certain to update the tag (v2 in this example).

![user input](images/userinput.png)

```

![user input](images/userinput.png)

Check the PATH of the newly committed image using the (v2) image ID.

![user input](images/userinput.png)

```
You can test the PATH by executing a `java` command inside the container.

![user input](images/userinput.png)

```