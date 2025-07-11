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



# Script generated for node SKU in Microsoft SQL Server
SKUinMicrosoftSQLServer_node1746555015996 = glueContext.create_dynamic_frame.from_options(
    connection_type = "sqlserver",
    connection_options = {
        "useConnectionProperties": "true",
        "dbtable": "Sku",
        "sampleQuery": "select distinct lps.guid lcom_suite_id, lps.salesforce_id SFDC_suite_id,  sku.SkuId, cast(SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time' as datetime) as LoadDate  from  CDSLicensing.dbo.learning_products_suite lps WITH (NOLOCK) join CDSLicensing.dbo.learning_products_suiteproduct lpsp WITH (NOLOCK) on lps.guid=lpsp.suite_id join CDSLicensing.dbo.learning_products_product lpp WITH (NOLOCK) on lpp.guid=lpsp.product_id join CDSLicensing.dbo.learning_platforms_learningcom_lcomplatformproduct lp_lpp WITH (NOLOCK) on lp_lpp.product_ptr_id = lpp.guid join ContentCatalog.dbo.Sku sku WITH (NOLOCK) on  sku.SkuId = lp_lpp.platform_sku_id",
        "connectionName": "PRD SQL ContentCatalog",
    },
    transformation_ctx = "SKUinMicrosoftSQLServer_node1746555015996"
)

# Script generated for node SKU in Amazon Redshift
SKUinAmazonRedshift_node1746555076349 = glueContext.write_dynamic_frame.from_options(frame=SKUinMicrosoftSQLServer_node1746555015996, connection_type="redshift", connection_options={"redshiftTmpDir": "s3://aws-glue-assets-248725110737-us-west-2/temporary/", "useConnectionProperties": "true", "dbtable": "staging.sku_suite", "connectionName": "PRD Redshift content_delivery_usage", "preactions": "TRUNCATE TABLE staging.sku_suite;"}, transformation_ctx="SKUinAmazonRedshift_node1746555076349")

job.commit()