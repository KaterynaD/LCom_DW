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

# Script generated for node SKU in Microsoft SQL Server
SKUinMicrosoftSQLServer_node1746555015996 = glueContext.create_dynamic_frame.from_options(
    connection_type = "sqlserver",
    connection_options = {
        "useConnectionProperties": "true",
        "dbtable": "Sku",
        "sampleQuery": "select distinct sku.SkuId, uci.CurriculumItemId, cast(SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time' as datetime) as LoadDate from ContentCatalog.dbo.Sku sku WITH (NOLOCK) join ContentCatalog.dbo.skuSequence skus WITH (NOLOCK) on skus.SkuId = sku.SkuId join ContentCatalog.dbo.Sequence s WITH (NOLOCK) on s.SequenceId = skus.SequenceId join ContentCatalog.dbo.SequenceUnit su WITH (NOLOCK) on su.SequenceId = skus.SequenceId join ContentCatalog.dbo.Unit u WITH (NOLOCK) on u.UnitId = su.UnitId join ContentCatalog.dbo.UnitCurriculumItems uci WITH (NOLOCK) on uci.UnitId = u.UnitId  where uci.auditUpdateDate>=cast('" +StartDate+ "' as date)",
        "connectionName": "PRD SQL ContentCatalog",
    },
    transformation_ctx = "SKUinMicrosoftSQLServer_node1746555015996"
)

# Script generated for node SKU in Amazon Redshift
SKUinAmazonRedshift_node1746555076349 = glueContext.write_dynamic_frame.from_options(frame=SKUinMicrosoftSQLServer_node1746555015996, connection_type="redshift", connection_options={"redshiftTmpDir": "s3://aws-glue-assets-248725110737-us-west-2/temporary/", "useConnectionProperties": "true", "dbtable": "staging.sku_learning_object_v2", "connectionName": "PRD Redshift content_delivery_usage", "preactions": "TRUNCATE TABLE staging.sku_learning_object_v2;"}, transformation_ctx="SKUinAmazonRedshift_node1746555076349")

job.commit()