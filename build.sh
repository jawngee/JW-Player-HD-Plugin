# This is a simple script that compiles the plugin using MXMLC (free & cross-platform).
# To use, make sure you have downloaded and installed the Flex SDK in the following directory:
FLEXPATH=/Developer/flex_3_2_0


echo "Compiling with MXMLC..."
$FLEXPATH/bin/mxmlc ./com/jeroenwijering/plugins/HD.as -sp ./ -o ./hd.swf -use-network=false