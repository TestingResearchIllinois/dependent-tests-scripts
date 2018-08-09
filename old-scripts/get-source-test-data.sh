# Get differences

echo "------------ Source ------------" >> diff-data.txt
echo "" >> diff-data.txt

echo "Ambari:" >> diff-data.txt
cloc --diff ambari/ambari-server/src/main/java/ ambari-new/ambari-server/src/main/java/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Crystal:" >> diff-data.txt
cloc --diff crystalvc/src/crystal/ crystal/src/crystal/ >> diff-data.txt
echo "" >> diff-data.txt

echo "JFreechart:" >> diff-data.txt
cloc --diff jfreechart-1.0.15/src/org/jfree/ jfreechart-1.0.16/src/org/jfree/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Jodatime:" >> diff-data.txt
cloc --diff jodatime-b609d7d66d/src/org/ jodatime-d6791cb5f9/src/main/java/org/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Synoptic:" >> diff-data.txt
cloc --diff dynoptic/src/ dynoptic-ea407ba0a750/src/ >> diff-data.txt
echo "" >> diff-data.txt

echo "XML-Security:" >> diff-data.txt
cloc --diff xml-security-orig-v1/src/org/ xml-security-1_2_0/src/org/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Zeppelin-Server:" >> diff-data.txt
cloc --diff zeppelin/zeppelin-server/src/main/java/ zeppelin-new/zeppelin-server/src/main/java/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Zeppelin-Zengine:" >> diff-data.txt
cloc --diff zeppelin/zeppelin-zengine/src/main/java/ zeppelin-zengine-new/zeppelin-zengine/src/main/java/ >> diff-data.txt
echo "" >> diff-data.txt
 
echo "------------ Test ------------" >> diff-data.txt
echo "" >> diff-data.txt

echo "Ambari:" >> diff-data.txt
cloc --diff ambari/ambari-server/src/test/java/ ambari-new/ambari-server/src/test/java/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Crystal:" >> diff-data.txt
cloc --diff crystalvc/tests/crystal/ crystal/tests/crystal/ >> diff-data.txt
echo "" >> diff-data.txt

echo "JFreechart:" >> diff-data.txt
cloc --diff jfreechart-1.0.15/tests/org/ jfreechart-1.0.16/tests/org/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Jodatime:" >> diff-data.txt
cloc --diff jodatime-b609d7d66d/tests/org/ jodatime-d6791cb5f9/tests/java/org/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Synoptic:" >> diff-data.txt
cloc --diff dynoptic/tests/dynoptic/ dynoptic-ea407ba0a750/tests/dynoptic/ >> diff-data.txt
echo "" >> diff-data.txt

echo "XML-Security:" >> diff-data.txt
cloc --diff xml-security-orig-v1/tests/org/ xml-security-1_2_0/tests/org/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Zeppelin-Server:" >> diff-data.txt
cloc --diff zeppelin/zeppelin-server/src/test/java/ zeppelin-new/zeppelin-server/src/test/java/ >> diff-data.txt
echo "" >> diff-data.txt

echo "Zeppelin-Zengine:" >> diff-data.txt
cloc --diff zeppelin/zeppelin-zengine/src/test/java/ zeppelin-zengine-new/zeppelin-zengine/src/test/java/ >> diff-data.txt
echo "" >> diff-data.txt

# Get LOC

echo "------------ Source ------------" >> loc-data.txt
echo "" >> loc-data.txt

echo "Ambari:" >> loc-data.txt
cloc ambari/ambari-server/src/main/java/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Crystal:" >> loc-data.txt
cloc crystalvc/src/crystal/ >> loc-data.txt
echo "" >> loc-data.txt

echo "JFreechart:" >> loc-data.txt
cloc jfreechart-1.0.15/src/org/jfree/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Jodatime:" >> loc-data.txt
cloc jodatime-b609d7d66d/src/org/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Synoptic:" >> loc-data.txt
cloc dynoptic/src/ >> loc-data.txt
echo "" >> loc-data.txt

echo "XML-Security:" >> loc-data.txt
cloc xml-security-orig-v1/src/org/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Zeppelin-Server:" >> loc-data.txt
cloc zeppelin/zeppelin-server/src/main/java/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Zeppelin-Zengine:" >> loc-data.txt
cloc zeppelin/zeppelin-zengine/src/main/java/ >> loc-data.txt
echo "" >> loc-data.txt
 
echo "------------ Test ------------" >> loc-data.txt
echo "" >> loc-data.txt

echo "Ambari:" >> loc-data.txt
cloc ambari/ambari-server/src/test/java/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Crystal:" >> loc-data.txt
cloc crystalvc/tests/crystal/ >> loc-data.txt
echo "" >> loc-data.txt

echo "JFreechart:" >> loc-data.txt
cloc jfreechart-1.0.15/tests/org/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Jodatime:" >> loc-data.txt
cloc jodatime-b609d7d66d/tests/org/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Synoptic:" >> loc-data.txt
cloc dynoptic/tests/dynoptic/ >> loc-data.txt
echo "" >> loc-data.txt

echo "XML-Security:" >> loc-data.txt
cloc xml-security-orig-v1/tests/org/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Zeppelin-Server:" >> loc-data.txt
cloc zeppelin/zeppelin-server/src/test/java/ >> loc-data.txt
echo "" >> loc-data.txt

echo "Zeppelin-Zengine:" >> loc-data.txt
cloc zeppelin/zeppelin-zengine/src/test/java/ >> loc-data.txt
echo "" >> loc-data.txt