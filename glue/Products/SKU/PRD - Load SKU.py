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
        "sampleQuery": "SELECT sku.SkuId,substring(sku.SkuName,1,100) SkuName,sku.Prefix,sku.PrefixRegex,substring(sku.Description,1,1000) Description,sku.ParentSkuId,sku.MsaId,sku.Stem,sku.ProductId,sku.ProviderID,sku.ResourcesHTML,sku.CanEnforceLicense,sku.IsVisibleUnlicensedSearch,sku.IsActive,sku.[Valid],sku.LastUpdatedDate,sku.LastUpdatedUser,sku.auditCreateDate,sku.auditUpdateDate,sku.IsHosted,sku.LowGrade,sku.HighGrade,sku.Subject,sku.SkuShortDescription,sku.MarketDescription,sku.ProductTaxTypeId,p.ProductName, cast(SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time' as datetime) as LoadDate FROM ContentCatalog.dbo.Sku sku with (NoLock) left outer join dbo.Product p with (NoLock) on sku.ProductId=p.ProductId",
        "connectionName": "PRD SQL ContentCatalog",
    },
    transformation_ctx = "SKUinMicrosoftSQLServer_node1746555015996"
)

# Script generated for node SKU in Amazon Redshift
SKUinAmazonRedshift_node1746555076349 = glueContext.write_dynamic_frame.from_options(frame=SKUinMicrosoftSQLServer_node1746555015996, connection_type="redshift", connection_options={"redshiftTmpDir": "s3://aws-glue-assets-248725110737-us-west-2/temporary/", "useConnectionProperties": "true", "dbtable": "staging.sku", "connectionName": "PRD Redshift content_delivery_usage", "preactions": "TRUNCATE TABLE staging.sku;"}, transformation_ctx="SKUinAmazonRedshift_node1746555076349")

job.commit()