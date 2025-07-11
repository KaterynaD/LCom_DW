import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME','StartDate'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

StartDate = args['StartDate']

# Script generated for node Sequence in Microsoft SQL Server
SeqinMicrosoftSQLServer_node1746555015996 = glueContext.create_dynamic_frame.from_options(
    connection_type = "sqlserver",
    connection_options = {
        "useConnectionProperties": "true",
        "dbtable": "Sequence",
        "sampleQuery": "select distinct s.SequenceId, s.SequenceName, s.SequenceDescription, s.IsValid, s.auditCreateDate,s.auditUpdateDate,s.IsLearningPathway, cast(case when ut.UnitTypeName != 'Unit' then 1 else 0 end as bit) isCustom, cast(SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time' as datetime) as LoadDate from ContentCatalog.dbo.Sequence s with (NoLock) join ContentCatalog.dbo.SequenceUnit su with (NoLock) on su.SequenceId = s.SequenceId  join  Unit u with (NoLock) on su.UnitId=u.UnitId join UnitType ut with (NoLock) on u.UnitTypeId=ut.UnitTypeId where s.auditCreateDate>=cast('" +StartDate+ "' as date)",
        "connectionName": "PRD SQL ContentCatalog",
    },
    transformation_ctx = "SeqinMicrosoftSQLServer_node1746555015996"
)

# Script generated for node Sequence in Amazon Redshift
SeqinAmazonRedshift_node1746555076349 = glueContext.write_dynamic_frame.from_options(frame=SeqinMicrosoftSQLServer_node1746555015996, connection_type="redshift", connection_options={"redshiftTmpDir": "s3://aws-glue-assets-248725110737-us-west-2/temporary/", "useConnectionProperties": "true", "dbtable": "staging.SEQUENCE", "connectionName": "PRD Redshift content_delivery_usage", "preactions": "TRUNCATE TABLE staging.SEQUENCE;"}, transformation_ctx="SeqinAmazonRedshift_node1746555076349")

job.commit()