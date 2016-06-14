public class SchemaHelpers {

	private static Map<String, Schema.SObjectType> globalSObjectTypeResults;
	private static Map<String, Schema.DescribeSObjectResult> globalDescribeResults;
	private static Map<String, Schema.SObjectField> sobjectTypeMap;
	private static Map<String, Schema.SObjectType> gd;

	public static Map<String, Schema.DescribeSObjectResult> getGlobalDescribeResults(){
		if(globalDescribeResults == null){
			globalSObjectTypeResults = new Map<String, Schema.SObjectType>();
			globalDescribeResults = new Map<String, Schema.DescribeSObjectResult>();
			gd = Schema.getGlobalDescribe();
			for(String sobjKey : gd.keySet()){
				Schema.SObjectType  sobjt = gd.get(sobjKey);
				DescribeSObjectResult sobjResult = sobjt.getDescribe();
				if(sobjResult.isQueryable()){
					globalDescribeResults.put(sobjResult.getLocalName().toLowerCase(), sobjResult);
					globalSObjectTypeResults.put(sobjResult.getLocalName().toLowerCase(), sobjt);
				}
			}
		}
		return globalDescribeResults;
	}

	public static Map<String, Schema.DescribeSObjectResult> getGlobalDescribeResults(String objectName){
		if(globalDescribeResults == null){
			globalSObjectTypeResults = new Map<String, Schema.SObjectType>();
			globalDescribeResults = new Map<String, Schema.DescribeSObjectResult>();
			gd = Schema.getGlobalDescribe();
			for(String sobjKey : gd.keySet()){
				Schema.SObjectType  sobjt = gd.get(sobjKey);
				DescribeSObjectResult sobjResult = sobjt.getDescribe();
				if(sobjResult.isQueryable()){
					globalDescribeResults.put(sobjResult.getLocalName().toLowerCase(), sobjResult);
					globalSObjectTypeResults.put(sobjResult.getLocalName().toLowerCase(), sobjt);
				}
			}
		}
		return globalDescribeResults;
	}

	public static DescribeSObjectResult getDescribeResult(String objectName){
		objectName = objectName.toLowerCase();
		if(SchemaHelpers.globalDescribeResults != null && SchemaHelpers.globalDescribeResults.containsKey(objectName)){
			return SchemaHelpers.globalDescribeResults.get(objectName);
		}else{
			return SchemaHelpers.getGlobalDescribeResults().get(objectName);
		}
	}

	public static Map<String, Schema.SObjectField> getSobjectTypeMapResults(String objectName){
		if(objectName != null){
			return SchemaHelpers.getDescribeResult(objectName).fields.getMap();
		}else{
			return null;
		}
	}

	public static Schema.sObjectType getRefrenceObject(String objectName, String fieldName){
		return SchemaHelpers.getFieldDescribe(objectName, fieldName).getReferenceTo()[0];
	}

	public static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldName){
		return SchemaHelpers.getSobjectTypeMapResults(objectName).get(fieldName).getDescribe();
	}

	public static Schema.DisplayType getFieldType(String objectName, String fieldName){
		return SchemaHelpers.getFieldDescribe(objectName, fieldName).getType();
	}

	public static String getNameField(String objectName){
		String name = '';
		Map<String, Schema.SObjectField> fields = getSobjectTypeMapResults(objectName);
		for(String sobjKey : fields.keySet()){
			if(fields.get(sobjKey).getDescribe().isNameField()){
				return fields.get(sobjKey).getDescribe().getName();
			}
		}
		return name;
	}

	public static String getObjectName(String objectName){
		String name = '';
		DescribeSObjectResult sobjResult = getDescribeResult(objectName);
		return sobjResult.getLabel();
	}

	public static String getObjectLabel(String objectName){
		DescribeSObjectResult sobjResult = getDescribeResult(objectName);
		return sobjResult.getLabel();
	}
	public static String getObjectLabelPlural(String objectName){
		String name = '';
		DescribeSObjectResult sobjResult = getDescribeResult(objectName);
		return sobjResult.getLabelPlural();
	}

	public SchemaHelpers() {}
}