public with sharing class SOQLReport {
public String id {get; set;}
public String objectName {get; set;}
public String query {get; set;}
public String fcSettingKeySet {get; set;}	
public Map<String, Schema.SObjectType> gd {get; set;}	
	
public class FieldLV{                    
 public String fieldLabel {get;set;}
 public String fieldValue {get;set;}
}
public class RecordContent{
	public String recordId {get;set;}
	public List<FieldLV> recordFields {get;set;}
}
public class tableContent{
	public String tableId {get;set;}
	public List<RecordContent> records {get;set;}
}
public class ObjectItem{
	public String objectName {get;set;}
	public List<String> fieldNames {get;set;}
}
public List<ObjectItem> objectFieldList {get;set;}

public List<SObject> result {get;set;}

public String jsonresult {get;set;}
public String fieldListStr {get;set;}
public List<String> fieldValue {get;set;}
public List<String> fieldList {get;set;}
public List<FieldLV> record{get;set;}
public String fieldValues {get;set;}


	public String getjsonresult(){
		return JSON.serializePretty(result);
	}
	
	public void drillSOQL(String soql){
		
		objectFieldList = new List<ObjectItem>();
		
		Integer startIndex = soql.indexOf('Select') + 6;
		Integer lastIndex = soql.lastIndexOf('From');
		String newsoql = soql.substring(startIndex, lastIndex);
		newsoql= newsoql.replaceAll('\\)', ' ');
		List<String> subqueries = newsoql.split('\\(');
		
		for(String query : subqueries){
			String baseObj = 'None';
			if(query.indexOf('Select')>=0){
				startIndex = soql.indexOf('Select') + 6;
				lastIndex = query.indexOf('From');
				String queryFrom = query.substring(lastIndex+4);
				queryFrom = queryFrom.trim();
				List<String> aQueryFrom = queryFrom.split(' ');
				for(String objname :aQueryFrom){
					if(objname!=null && objname.length()>0){
						baseObj = objname;
						break;
					}
				}
				
				query = query.substring(startIndex, lastIndex);
				List<String> fieldList = query.split(',');
				for(String field : fieldList){
					
				}
			}
	
		}
		
		
		
	}
	
	public SOQLReport() {
		 id  = ApexPages.currentPage().getParameters().get('id');

		 List<SOQL_Report__c>  soqlL = [Select SOQL_Source__c From SOQL_Report__c Where Id = :id];

		 if(soqlL.size()>0){
		 	String soql = soqlL[0].SOQL_Source__c;
		 	Integer startIndex = soql.indexOf('Select') + 6;
		 	Integer lastIndex = soql.indexOf('From');
		 	fieldListStr = soql.substring(startIndex, lastIndex);
		 	fieldList = fieldListStr.split(',');

		 	List<SObject> result = Database.query(soql);
		 	for(SObject sobj : result){
		 		for(String field : fieldList){
		 			field = field.trim();
		 			List<String> fielda = field.split('\\.');
		 			if(fielda.size()==1){
		 				//fieldValues = (String) sobj.get(fielda[0]);
		 			}else if( fielda[0]=='OpportunityLineItems'){
		 				
		 				List<SObject> o0 = sobj.getSObjects(fielda[0]);
						
		 				for( Sobject o : o0){
		 					fieldValues = fieldValues + (String) o.get(fielda[1]);
		 				}
		 			}
		 		}
		 	}
		 }
		 
		 
		 
		/*
		 String keyCode  = id.subString(0,3);

		 gd = Schema.getGlobalDescribe();
		 List<FieldLV> lvl = new List<FieldLV>();
		 String reportName = 'Campaign';
					 
		 List<CS_FCPrintableSetting__c> printSettingList = getRelatedPrintSettings(reportName);
		 for(CS_FCPrintableSetting__c printSetting : printSettingList){
		 	List<SObject> queryResult = getQueryResult(printSetting, id);
		 	List<String> fieldList = printSetting.ObjectQuery1__c.split(',');
		 	String fieldName;
		 	String fieldLabel;
		 	String objectName;
		 	String labelFieldKey;
		 	String fieldValue;
		 	for(SObject resultObj : queryResult){
			 	for(String fullFieldName : fieldList){
			 		 objectName = printSetting.Object_API_Name__c;
			 		 objectName = objectName.trim();
			 		 			 		
			 		 if(fullFieldName.indexOf('.')<0){
			 		 	fieldName = fullFieldName.trim();
			 		 	labelFieldKey = fieldName;

			 		 	fieldValue  = getFCFormatValue( resultObj.get(fieldName), objectName, fieldName);
			 		 	
			 		 }else{
			 		 	List<String> fullFieldList =fullFieldName.split('\\.');
			 		 	fieldName = fullFieldList.get(0).trim();		
			 		 	labelFieldKey = fieldName.replace('__r','__c');
	 					SObject childObject =  resultObj.getSObject(fieldName);

	 					if(childObject==null){
	 						fieldValue = '';
	 					} else {
	 						fieldValue  = getFCFormatValue( childObject.get(fullFieldList.get(1).trim()), 
	 						objectName, fullFieldList.get(1).trim() );
	 					}
			 		 }
			 		 

			 		 fieldLabel= getFCFieldLabel(   objectName,  labelFieldKey);
			 		 
			 		
			 		 
					FieldLV objnam = new FieldLV();
					objnam.fieldLabel = fieldLabel;
					objnam.fieldValue = fieldValue ;					
					lvl.add(objnam);		 		 
			 	}
		 	}
		 }
		 

		 record = lvl;
		 */

	}
	public String getFCFormatValue( Object val, String objectName, String fieldName){
		

		Schema.DescribeSObjectResult objectDescribe = gd.get(objectName).getDescribe();

		Schema.SObjectField objectField = objectDescribe.fields.getMap().get(fieldName);
		Schema.DescribeFieldResult objectFieldDescribe = objectField.getDescribe();
		Schema.DisplayType objectType = objectFieldDescribe.getType();
		
		String stringVal='';

		if(objectType == Schema.DisplayType.DateTime){

			DateTime dtval = (DateTime)val;
			stringVal = dtval.format('dd/MM/yy');
		} else if(objectType == Schema.DisplayType.Boolean){

			Boolean bl = (Boolean)val;
			stringVal = bl ? 'Yes':'No';

		}else{
			stringVal=(String)val;
		} 
		//dtval.format('dd/MM/yy');
		return stringVal;
	}
		
	public String getFCFieldLabel(String objectName, String fieldName){
		Schema.DescribeSObjectResult objectDescribe = gd.get(objectName).getDescribe();
		String label='';
		Schema.SObjectField objectField = objectDescribe.fields.getMap().get(fieldName);
		if(objectField!=null){
			Schema.DescribeFieldResult objectFieldDescribe = objectField.getDescribe();
			label = objectFieldDescribe.getLabel();
		}else{
			label = fieldName + 'notfound';
		}	
		return label;
	}
	public String getAllFCFieldLabel(String objectName){
		Schema.DescribeSObjectResult objectDescribe = gd.get(objectName).getDescribe();
		String label='';

		for(String key : objectDescribe.fields.getMap().keySet()){
			Schema.SObjectField objectField = objectDescribe.fields.getMap().get(key);
			Schema.DescribeFieldResult objectFieldDescribe = objectField.getDescribe();

			label += '>key:' + key +' value:'+objectFieldDescribe.getLabel();
		}	
		return label;
	}	
	/*
	public List<CS_FCPrintableSetting__c> getRelatedPrintSettings(String displayKey){
		
		List<CS_FCPrintableSetting__c> printSetting = new List<CS_FCPrintableSetting__c>();
		Map<String, CS_FCPrintableSetting__c> fcset = CS_FCPrintableSetting__c.getAll();
		Integer ctr = 1;
		String newkey ='';
		while(ctr>0){
			newkey = displayKey + '-' + ctr;
			CS_FCPrintableSetting__c fcConfig = fcset.get( newkey );
			if(fcConfig==null){
				ctr = 0; //to break the loop;
			}else{
				ctr++;
				printSetting.add( fcConfig );
			}
		}
		return printSetting;
	}
		
	public List<SObject> getQueryResult(CS_FCPrintableSetting__c fcConfig, String objectId){
		List<SObject> result;

		query = 'SELECT ';
		query += fcConfig.ObjectQuery1__c;
		query += ' From ' + fcConfig.Object_API_Name__c;
		query += ' Where Id=\'' + objectId + '\'';

		result = Database.query (query); 
		return result;	
	}
	*/
	
}