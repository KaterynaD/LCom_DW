import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for educational standard alignments
SqlQuery_Alignments = '''
select lower(CurriculumItemId) as learning_object_id
     , StandardTopicId as standard_topic_id
     , IsManual as is_manual
     , auditCreateDate as created_datetime
  from dbo.EgItemAlignment
'''

# Script generated for node Get Alignment Data
GetAlignmentData_node1 = glueContext.create_dynamic_frame.from_options(
    connection_type = "sqlserver",
    connection_options = {
        "useConnectionProperties": "true",
        "dbtable": "dbo.EgItemAlignment",
        "sampleQuery": SqlQuery_Alignments,
        "connectionName": "PRD SQL ContentCatalog",
    },
    transformation_ctx = "GetAlignmentData_node1"
)

# Script generated for node Amazon Redshift
AmazonRedshift_node1 = glueContext.write_dynamic_frame.from_options(frame=GetAlignmentData_node1, connection_type="redshift", connection_options={"redshiftTmpDir": "s3://aws-glue-assets-248725110737-us-west-2/temporary/", "useConnectionProperties": "true", "dbtable": "staging.learning_object_standard", "connectionName": "PRD Redshift content_delivery_usage", "preactions": "CREATE TABLE IF NOT EXISTS staging.learning_object_standard (learning_object_id VARCHAR(255), standard_topic_id INT, is_manual BOOLEAN, created_datetime TIMESTAMP); TRUNCATE TABLE staging.learning_object_standard;"}, transformation_ctx="AmazonRedshift_node1")

job.commit()