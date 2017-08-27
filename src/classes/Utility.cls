public class Utility {


	//--------------------------------------------------------------------------
	// Utility functions
	/**
	 * utility method for determining if an object is null or blank.
	 *  For strings, 'blank' means empty or only whitespace. A 'blank' List has
	 *  no elements.
	 * <p>
	 * <b>WARNING</b> this method doesn't work with Set or Map
	 */
	public static Boolean isEmpty(Object o) {
		if (null == o) {
			return true;
		} else if (o instanceof String) {
			return(0 == ((String) o).trim().length());
		} else if (o instanceof List<Object>) {
			return(0 == ((List<Object>) o).size());
		} else if(o instanceof Map<Object, Object>){
			return(0 == ((Map<Object, Object>) o).size());
		} else if(o instanceof Set<Object>){
			return (0 == ((Set<Object>) o).size());
		} else {
			SF.preCondition(false, 'SF.isEmpty() - invalid object type');
			return false;
		}
	}

    public static Boolean isEqual(String s1, String s2) {
        return (String.isEmpty(s1) && String.isEmpty(s2)) || (s1 == s2);
    }

    public static Boolean isNotEqual(String s1, String s2) {
        return !isEqual(s1, s2);
    }

	/** return the specified string page parameter, or 'defaultValue' */
	public static String getPageParam(String key, String defaultValue) {
		SF.preCondition(!isEmpty(key), 'SF.getPageParam() - key is required');

		final String param = ApexPages.currentPage().getParameters().get(key);
		return(null == param) ? defaultValue : param;
	}

	/** return the specified integer page parameter, or 'defaultValue' */
	public static Integer getPageParam(String key, Integer defaultValue) {
		SF.preCondition(!isEmpty(key), 'SF.getPageParam() - key is required');

		try {
			if (ApexPages.currentPage().getParameters().containsKey(key)) {
				return Integer.valueOf(ApexPages.currentPage().getParameters().get(key));
			}
		} catch(Exception e) {
		}

		return defaultValue;
	}

	/**
	 * @param key query parameter accepting comma-separated list of values
	 * @return values as an array of strings
	 */
	public static String[] getPageParams(String key) {
		final String param = getPageParam(key, (String) null);
		final String[] result = ((null != param) && ('null' != param)) ? param.split(',') : new String[] { };
		SF.postCondition(result != null, 'SF.getPageParams() - null result');
		return result;
	}

	/**
	 * return the unique values for a given field in a list of records. Null is not included.
	 * @param objects the list of records
	 * @param field values from this field will be returned
	 * @return set of values; no null
	 */
	public static Set<String> getFieldValues(SObject[] objects, SObjectField field) {
		return getFieldValues(objects, field.getDescribe().getName());
	}

	public static Set<String> getFieldValues(SObject[] objects, String field) {
    SF.preCondition(field != null, 'SF.getFieldValues() - field is required');

		Set<String> result = new Set<String> ();
		if (!isEmpty(objects)) {
			for (SObject o : objects) {
				result.add(String.valueOf(o.get(field)));
			}
			result.remove(null);
		}

		SF.postCondition(result != null, 'SF.getFieldValues() - null result');
		SF.postCondition(!result.contains(null), 'SF.getFieldValues() - null value');
		return result;
	}

	/**
	 * return the unique Ids in a list of records.
	 * @param objects the list of records
	 * @return set of Ids; no null
	 */
	public static Set<String> getIds(SObject[] objects) {
		return getFieldValues(objects, Case.Id);
	}

	/** return true if the trigger for the specified object is active */
	public static Boolean isTriggerActive(SObjectType o) {
		SF.preCondition(null != o, 'SF.isTriggerActive() - object type is required');

		// first check the global trigger flag
		try {
			/*if (false == Boolean.valueOf(Config__c.getInstance().get('Enable_Triggers__c'))) {
				return false;
			}*/
		}
		catch(Exception ex) { }

		final String triggerName = String.valueOf(o).removeEnd('__c');

		try {
			//To-Do: uncomment it
      //BaseTest.throwIfTesting(new NullPointerException());
			/*if (false == Boolean.valueOf(Config__c.getInstance().get('Enable_' + triggerName + '_Triggers__c'))) {
				return false;
			}*/
		}
		catch(Exception ex) { }

		return true;
	}

	/** Merge value of two multi-select picklist */
	public static String gather(String current, String leadTehnology) {
		Set<String> allUniqueValues = new Set<String> ();
		if (null != current) allUniqueValues.addAll(current.split(';'));
		if (null != leadTehnology) allUniqueValues.addAll(leadTehnology.split(';'));

		return String.join(new List<String> (allUniqueValues), ';');
	}

	/** Return 0 if null */
	public static Integer getNumeric(Integer o) {
		return(null == o) ? 0 : o;
	}

	public static Decimal getNumeric(Decimal o) {
		return(null == o) ? 0 : o;
	}

	/** Convert to Integer */
	public static Integer toInteger(Object value) {
		Integer result = null;

		try {
			result = Integer.valueOf(value);
		} catch(Exception ex) {
		}

		return result;
	}

	/** Returns the larger of the two specified Dates. */
	public static Date max(Date d1, Date d2) {
		Date result;
		if (null != d1 && null != d2) {
			result = d1 > d2 ? d1 : d2;
		} else {
			result = null != d1 ? d1 : d2;
		}

		return result;
	}

	/** Returns the smallest of the two specified Dates. */
	public static Date min(Date d1, Date d2) {
		Date result;
		if (null != d1 && null != d2) {
			result = d1 < d2 ? d1 : d2;
		} else {
			result = null != d1 ? d1 : d2;
		}

		return result;
	}

	/** Add value(s) to the multiselect picklist if it does not contain them
	  @param multiPicklist to update
	  @param values to update with
	  @return null if any changes have not been made or processed multiselect picklist as a result in other case
	 */
	public static String processMultiselectPicklist(String multiPicklist, String toUpdateWith) {
		if (toUpdateWith == null) return null;
		if (multiPicklist == null) return toUpdateWith;

		Set<String> valuesOfMultiPicklist = new Set<String> (multiPicklist.split(';'));
		List<String> valuesToAdd = new List<String> ();

		for (String valueToUpdateWith : toUpdateWith.split(';')) {
			if (!valuesOfMultiPicklist.contains(valueToUpdateWith)) {
				valuesToAdd.add(valueToUpdateWith);
			}
		}

		//TODO has to be replaced with something like java class StringBuilder
		if (!valuesToAdd.isEmpty()) {
			String resultToAdd = '';
			for (String valueToAdd : valuesToAdd) {
				resultToAdd += valueToAdd + ';';
			}
			return resultToAdd + multiPicklist;
		}
		return null;

	}

  /**
   * String formatting short cut
   * <p>
   * Note: single apostrophes need to be double escaped.
   * @see String.format
   */
  public static String format(String format, Object arg1) {
    SF.preCondition(format != null, 'SF.format() - format is required');
    
    return String.format(format.replaceAll('\'', '\'\''), new String[] {
      String.valueOf(arg1)});
  }
  
  public static String format(String format, Object arg1, Object arg2) {
    SF.preCondition(format != null, 'SF.format() - format is required');
    
    return String.format(format.replaceAll('\'', '\'\''), new String[] {
      String.valueOf(arg1), String.valueOf(arg2)});
  }
  
  public static String format(String format, Object arg1, Object arg2, Object arg3) {
    SF.preCondition(format != null, 'SF.format() - format is required');
    
    return String.format(format.replaceAll('\'', '\'\''), new String[] {
      String.valueOf(arg1), String.valueOf(arg2), String.valueOf(arg3)});
  }

  //--------------------------------------------------------------------------
  // Date utility functions
  public static Boolean isPrevMonth(Date d) {
    return d < Date.today().toStartofMonth();
  }


  //--------------------------------------------------------------------------
  // SOQL utility functions

  /**
   * Select all fields from object that can be created  by the current user
   * @param soType SObjectType of query object
   */
  public static String selectAllCreateableField(Schema.SObjectType soType) {
    List<String> fields = new List<String>();
    for (Schema.SObjectField field : soType.getDescribe().fields.getMap().values()) {
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
      if (fieldDescribe.isCreateable()) {
        fields.add(fieldDescribe.getName());
      }
    }

    if (fields.size() > 0) {
      fields.add(0, '');
    }

    return format('SELECT Id{0} FROM {1}', String.join(fields, ','), '' + soType);
  }

  /**
   * Select all fields from object that can be accessible  by the current user
   * @param soType SObjectType of query object
   */
  public static String selectAllAccessibleField(Schema.SObjectType soType) {
    List<String> fields = new List<String>();
    for (Schema.SObjectField field : soType.getDescribe().fields.getMap().values()) {
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
      if (fieldDescribe.isAccessible()) {
        fields.add(fieldDescribe.getName());
      }
    }

    return format('SELECT {0} FROM {1}', String.join(fields, ','), '' + soType);
  }

}