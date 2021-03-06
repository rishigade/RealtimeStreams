/*
 * Copyright 2019 Infosys Ltd.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
INSERT  INTO tbl_template(tmplte_id,tmplte_file_four,tmplte_file_one,tmplte_file_three,tmplte_file_two,tmplte_prcs_type,tmplte_sink_type,tmplte_src_type,tmplte_name,tmplte_data_type,tmplte_lookup_type,tmplte_algorithm_type)
VALUES (3,NULL, '#!/usr/bin/python
from __future__ import print_function

import sys
from pyspark.context import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql import Row
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
from pyspark.conf import SparkConf
from cassandra import ConsistencyLevel
from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement
from pyspark.streaming.flume import FlumeUtils
from pyspark.sql.functions import monotonically_increasing_id

from pyspark.sql.functions import lit
import time as tval
from pyspark.sql.types import StringType
from pyspark.sql.types import IntegerType
from pyspark.sql.types import LongType
from pyspark.sql.types import DoubleType
from pyspark.sql.types import FloatType
from pyspark.sql.types import StructType
from pyspark.sql.types import StructField
from pyspark.sql import Row
import uuid
import pyspark.sql.functions
import random
import logging

log = logging.getLogger()
log.setLevel(\'DEBUG\')
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(name)s: %(message)s"))
log.addHandler(handler)

$DEFINE_USER_FUNC$

def getSqlContextInstance(sparkContext):
    if (\'sqlContextSingletonInstance\' not in globals()):
    	sqlContext = SQLContext(sparkContext)
    	$REGISTER_USER_FUNC$
        globals()[\'sqlContextSingletonInstance\'] = sqlContext
    return globals()[\'sqlContextSingletonInstance\']

$CREATE_TABLE_FUNC$
	
$PROCESS_LOGIC_FUNC$
	
if __name__ == "__main__":
	
	log.info("Start Application...")
	
	sinkNode = "$SINK_NODELST$"
	execMode = "$EXEC_MODE$"
	appName = "$SPARK_APPNAME$"
	flumeagentsinkhost = "$FLUME_SINKHOST$"
	flumeagentsinkport = $FLUME_SINKPORT$
	
	conf = SparkConf()
	conf.setMaster(execMode)
	conf.setAppName(appName)
	conf.set("spark.cassandra.connection.host", sinkNode)
	
	$ADDITIONAL_PARAMETERS$	
	
	sc = SparkContext(conf=conf)
	ssc = StreamingContext(sc, $SPARK_BATCH_INTERVAL$)
	ssc.checkpoint("$CHECK_POINT_DIR$")

	log.info("Creating tables...")
	createTables()
	
	log.info("Start Streaming...")
	flumeStream = FlumeUtils.createStream(ssc,flumeagentsinkhost,flumeagentsinkport)	
	
	$PARSING_LOGIC$
	
	$ITERATIVE_LOGIC$
	
	ssc.start()
	ssc.awaitTermination()',NULL,NULL,'spark','elassandra','flume',NULL,'unstructured',NULL,NULL);