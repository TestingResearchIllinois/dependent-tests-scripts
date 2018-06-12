# This file is to share variables and functions. Please do not run this file.
rootDir=$1
# The name of the subject you wish to add (e.g., xml_security).
expName=(
  crystal
  jfreechart
  jodatime
  synoptic
  xml_security
  zeppelin-server
  # xstream
  # pdfbox
  activemqCamel
  ambari-server
  zeppelin-zeppelin-zengine
)
# Directory for where all of the old subject's information is stored.
expDirectories=(
  ${rootDir}/crystalvc
  ${rootDir}/jfreechart-1.0.15
  ${rootDir}/jodatime-b609d7d66d
  ${rootDir}/dynoptic
  ${rootDir}/xml-security-orig-v1
  ${rootDir}/zeppelin/zeppelin-server/target
  # ${rootDir}/xstream-1.2/xstream/target
  # ${rootDir}/pdfbox-old/pdfbox/target
  ${rootDir}/activemq-old/activemq-camel/target
  ${rootDir}/ambari-old-c088e59ebcf099b01603d883dce7700d44cabc68/ambari-server/target
  ${rootDir}/zeppelin-old-0f81b6d6132471ddf0e91cc3738da1ff365604f8/zeppelin-zengine/target
)
# Classpath to run the old subject's automatically-generated and human-written tests.
expCP=(
  ${rootDir}/crystalvc/bin/:${rootDir}/crystalvc/lib/*
  ${rootDir}/jfreechart-1.0.15/bin/:${rootDir}/jfreechart-1.0.15/lib/*
  ${rootDir}/jodatime-b609d7d66d/bin/:${rootDir}/jodatime-b609d7d66d/resources/:${rootDir}/jodatime-b609d7d66d/lib/*
  ${rootDir}/dynoptic/bin/:${rootDir}/synoptic/lib/*:${rootDir}/synoptic/bin/:${rootDir}/daikonizer/bin/
  ${rootDir}/xml-security-orig-v1/bin/:${rootDir}/xml-security-commons/bin/:${rootDir}/xml-security-orig-v1/data/:${rootDir}/xml-security-commons/libs/*
  ${rootDir}/zeppelin/zeppelin-server/target/classes/:${rootDir}/zeppelin/zeppelin-server/target/test-classes/:${rootDir}/zeppelin/zeppelin-server/target/dependency/*:${rootDir}/zeppelin/zeppelin-server/target/randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*:
  # ${rootDir}/xstream-1.2/xstream/target/dependency/*:${rootDir}/xstream-1.2/xstream/target/classes:${rootDir}/xstream-1.2/xstream/target/randoop/bin:${rootDir}/xstream-1.2/xstream/target/test-classes:
  # ${rootDir}/pdfbox-old/pdfbox/target/dependency/*:${rootDir}/pdfbox-old/pdfbox/target/classes:${rootDir}/pdfbox-old/pdfbox/target/randoop/bin:${rootDir}/pdfbox-old/pdfbox/target/test-classes:
  ${rootDir}/activemq-old/activemq-camel/target/dependency/*:${rootDir}/activemq-old/activemq-camel/target/classes:${rootDir}/activemq-old/activemq-camel/target/randoop/bin:${rootDir}/activemq-old/activemq-camel/target/test-classes:
  ${rootDir}/ambari-old-c088e59ebcf099b01603d883dce7700d44cabc68/ambari-server/target/dependency/*:${rootDir}/ambari-old-c088e59ebcf099b01603d883dce7700d44cabc68/ambari-server/target/classes:${rootDir}/ambari-old-c088e59ebcf099b01603d883dce7700d44cabc68/ambari-server/target/randoop/bin:${rootDir}/ambari-old-c088e59ebcf099b01603d883dce7700d44cabc68/ambari-server/target/test-classes:
  ${rootDir}/zeppelin-old-0f81b6d6132471ddf0e91cc3738da1ff365604f8/zeppelin-zengine/target/dependency/*:${rootDir}/zeppelin-old-0f81b6d6132471ddf0e91cc3738da1ff365604f8/zeppelin-zengine/target/classes:${rootDir}/zeppelin-old-0f81b6d6132471ddf0e91cc3738da1ff365604f8/zeppelin-zengine/target/randoop/bin:${rootDir}/zeppelin-old-0f81b6d6132471ddf0e91cc3738da1ff365604f8/zeppelin-zengine/target/test-classes:
)
# The name of the subject you want to be displayed in the paper (e.g., XML Security).
expNameFormal=(
  "Crystal"
  "JFreechart"
  "Joda-Time"
  "Synoptic"
  "XML Security"
  "Zeppelin-Server"
  # "XStream"
  # "PDFBox"
  "ActivemqCamel"
  "Ambari-Server"
  "Zeppelin-Zengine"
)
# Directory for where all of the new subject's information is stored.
nextExpDirectories=(
  ${rootDir}/crystal
  ${rootDir}/jfreechart-1.0.16
  ${rootDir}/jodatime-d6791cb5f9
  ${rootDir}/dynoptic-ea407ba0a750
  ${rootDir}/xml-security-1_2_0
  ${rootDir}/zeppelin-new/zeppelin-server/target
  # ${rootDir}/xstream-1.2.1/xstream/target
  # ${rootDir}/pdfbox-new/pdfbox/target
  ${rootDir}/activemq-new/activemq-camel/target
  ${rootDir}/ambari-new-ad9bcb645dd5c743924d548b889e12185345b523/ambari-server/target
  ${rootDir}/zeppelin-new-6353732095af880944b8c09eacc3ab7eaf64e7e0/zeppelin-zengine/target
)
# Classpath to run the new subject's automatically-generated and human-written tests.
nextExpCP=(
  ${rootDir}/crystal/bin/:${rootDir}/crystal/lib/*
  ${rootDir}/jfreechart-1.0.16/bin/:${rootDir}/jfreechart-1.0.16/lib/*
  ${rootDir}/jodatime-d6791cb5f9/bin/:${rootDir}/jodatime-d6791cb5f9/resources/:${rootDir}/jodatime-d6791cb5f9/lib/*
  ${rootDir}/dynoptic-ea407ba0a750/bin/:${rootDir}/synoptic/lib/*:${rootDir}/synoptic-ea407ba0a750/bin/:${rootDir}/daikonizer-ea407ba0a750/bin/
  ${rootDir}/xml-security-1_2_0/bin/:${rootDir}/xml-security-commons/bin/:${rootDir}/xml-security-1_2_0/data/:${rootDir}/xml-security-commons/libs/*
  ${rootDir}/zeppelin-new/zeppelin-server/target/classes/:${rootDir}/zeppelin-new/zeppelin-server/target/test-classes/:${rootDir}/zeppelin-new/zeppelin-server/target/dependency/*:${rootDir}/zeppelin-new/zeppelin-server/target/randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*:
  # ${rootDir}/xstream-1.2.1/xstream/target/dependency/*:${rootDir}/xstream-1.2.1/xstream/target/classes:${rootDir}/xstream-1.2.1/xstream/target/randoop/bin:${rootDir}/xstream-1.2.1/xstream/target/test-classes:
  # ${rootDir}/pdfbox-new/pdfbox/target/dependency/*:${rootDir}/pdfbox-new/pdfbox/target/classes:${rootDir}/pdfbox-new/pdfbox/target/randoop/bin:${rootDir}/pdfbox-new/pdfbox/target/test-classes:
  ${rootDir}/activemq-new/activemq-camel/target/dependency/*:${rootDir}/activemq-new/activemq-camel/target/classes:${rootDir}/activemq-new/activemq-camel/target/randoop/bin:${rootDir}/activemq-new/activemq-camel/target/test-classes:
  ${rootDir}/ambari-new-ad9bcb645dd5c743924d548b889e12185345b523/ambari-server/target/dependency/*:${rootDir}/ambari-new-ad9bcb645dd5c743924d548b889e12185345b523/ambari-server/target/classes:${rootDir}/ambari-new-ad9bcb645dd5c743924d548b889e12185345b523/ambari-server/target/randoop/bin:${rootDir}/ambari-new-ad9bcb645dd5c743924d548b889e12185345b523/ambari-server/target/test-classes:
  ${rootDir}/zeppelin-new-6353732095af880944b8c09eacc3ab7eaf64e7e0/zeppelin-zengine/target/dependency/*:${rootDir}/zeppelin-new-6353732095af880944b8c09eacc3ab7eaf64e7e0/zeppelin-zengine/target/classes:${rootDir}/zeppelin-new-6353732095af880944b8c09eacc3ab7eaf64e7e0/zeppelin-zengine/target/randoop/bin:${rootDir}/zeppelin-new-6353732095af880944b8c09eacc3ab7eaf64e7e0/zeppelin-zengine/target/test-classes:
)
# Directory containing the old subject's src directory. These directories contain projects that were originally built with Ant.
antExp=(
  ${rootDir}/crystalvc
  ${rootDir}/jfreechart-1.0.15
  ${rootDir}/jodatime-b609d7d66d
  ${rootDir}/dynoptic
  ${rootDir}/xml-security-orig-v1
)
# Directory containing the new subject's src directory. These directories contain projects that were originally built with Ant.
antNextExp=(
  ${rootDir}/crystal
  ${rootDir}/jfreechart-1.0.16
  ${rootDir}/jodatime-d6791cb5f9
  ${rootDir}/dynoptic-ea407ba0a750
  ${rootDir}/xml-security-1_2_0
)
# Directory containing the old subject's src directory. These directories contain projects that were originally built with Maven.
antMvnExp=(
  ${rootDir}/zeppelin/zeppelin-server
  # ${rootDir}/xstream-1.2/xstream
  # ${rootDir}/pdfbox-old/pdfbox
  ${rootDir}/activemq-old/activemq-camel
  ${rootDir}/ambari-old-c088e59ebcf099b01603d883dce7700d44cabc68/ambari-server
  ${rootDir}/zeppelin-old-0f81b6d6132471ddf0e91cc3738da1ff365604f8/zeppelin-zengine
)
# Directory containing the new subject's src directory. These directories contain projects that were originally built with Maven.
antMvnNextExp=(
  ${rootDir}/zeppelin-new/zeppelin-server
  # ${rootDir}/xstream-1.2.1/xstream
  # ${rootDir}/pdfbox-new/pdfbox/
  ${rootDir}/activemq-new/activemq-camel
  ${rootDir}/ambari-new-ad9bcb645dd5c743924d548b889e12185345b523/ambari-server
  ${rootDir}/zeppelin-new-6353732095af880944b8c09eacc3ab7eaf64e7e0/zeppelin-zengine
)
antMvnCP=(
  ${rootDir}/zeppelin/zeppelin-server/target/classes/:${rootDir}/zeppelin/zeppelin-server/target/test-classes/:${rootDir}/zeppelin/zeppelin-server/target/dependency/*:${rootDir}/zeppelin/zeppelin-server/target/randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*:
  # ${rootDir}/xstream-1.2/xstream/target/dependency/*:${rootDir}/xstream-1.2/xstream/target/classes:${rootDir}/xstream-1.2/xstream/target/randoop/bin:${rootDir}/xstream-1.2/xstream/target/test-classes:
  # ${rootDir}/pdfbox-old/pdfbox/target/dependency/*:${rootDir}/pdfbox-old/pdfbox/target/classes:${rootDir}/pdfbox-old/pdfbox/target/randoop/bin:${rootDir}/pdfbox-old/pdfbox/target/test-classes:
  ${rootDir}/activemq-old/activemq-camel/target/dependency/*:${rootDir}/activemq-old/activemq-camel/target/classes:${rootDir}/activemq-old/activemq-camel/target/randoop/bin:${rootDir}/activemq-old/activemq-camel/target/test-classes:
)
antMvnNextCP=(
  ${rootDir}/zeppelin-new/zeppelin-server/target/classes/:${rootDir}/zeppelin-new/zeppelin-server/target/test-classes/:${rootDir}/zeppelin-new/zeppelin-server/target/dependency/*:${rootDir}/zeppelin-new/zeppelin-server/target/randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*:
  # ${rootDir}/xstream-1.2.1/xstream/target/dependency/*:${rootDir}/xstream-1.2.1/xstream/target/classes:${rootDir}/xstream-1.2.1/xstream/target/randoop/bin:${rootDir}/xstream-1.2.1/xstream/target/test-classes:
  # ${rootDir}/pdfbox-new/pdfbox/target/dependency/*:${rootDir}/pdfbox-new/pdfbox/target/classes:${rootDir}/pdfbox-new/pdfbox/target/randoop/bin:${rootDir}/pdfbox-new/pdfbox/target/test-classes:
  ${rootDir}/activemq-new/activemq-camel/target/dependency/*:${rootDir}/activemq-new/activemq-camel/target/classes:${rootDir}/activemq-new/activemq-camel/target/randoop/bin:${rootDir}/activemq-new/activemq-camel/target/test-classes:
)
