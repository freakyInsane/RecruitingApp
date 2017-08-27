/**
 * A utility class for app-wide constants, exceptions, and utility functions
 */
public class SF {
	//--------------------------------------------------------------------------
	// Constants

	/** the prefix to use on all System.debug calls */
	@TestVisible private static final String DEBUG_PREFIX = '~ ';

	//--------------------------------------------------------------------------
	// Exceptions
	/** base class for all exceptions */
	public abstract class SF_Exception extends Exception {
	}

	/** a failed assertion */
	public class AssertionException extends SF_Exception {
	}

	/** a data validation error of some sort */
	public class ValidationException extends SF_Exception {
	}

	/** error in trigger definition or setup */
	public class TriggerException extends SF_Exception {
	}

	/** HTTP error, including the status code */
	public class HttpException extends SF_Exception {
		public Integer code { get; private set; }

		public HttpException(Integer code, String msg) {
			this(msg);
			this.code = code;
		}
	}

	//--------------------------------------------------------------------------
	// Diagnostics
	/** Use this flag to conditionally provide diagnostics */
	public static Boolean debugging { get { return /*Config__c.getInstance().debugging__c;*/ false; } }

	/** Write an error message to the log */
	public static void error(Object message) {
		debug(LoggingLevel.ERROR, message);
	}

	/** Write a warning message to the log */
	public static void warn(Object message) {
		debug(LoggingLevel.WARN, message);
	}

	/** Write an info message to the log */
	public static void info(Object message) {
		debug(LoggingLevel.INFO, message);
	}

	/** Write a debug message to the log */
	public static void debug(Object message) {
		debug(LoggingLevel.DEBUG, message);
	}

	/** begin a debugging 'context'. Subsequent logging calls will be indented */
	public static void debugBegin(Object message) {
		cachingDebugEntries = true;
		debug(LoggingLevel.DEBUG, message);
		++ debugEntryLevel;
	}

	/** end a debugging 'context'. Subsequent logging calls will be outdented */
	public static void debugEnd() {
		if (debugEntryLevel > 0) {
			-- debugEntryLevel;
		}

		if ((0 == debugEntryLevel) && debugging) {
			System.debug(LoggingLevel.ERROR, debugEntriesToString());
			debugEntries.clear();
			cachingDebugEntries = false;
		}
	}

	/** end all debugging 'contexts'. Indent level is set back to 0 */
	public static void debugEndAll() {
		debugEntryLevel = 0;
		debugEnd();
	}

	/** when debugging, log and create an Log__c entry for the specified exception */
	public static void debugException(Exception ex) {
		if (debugging) {
			final Boolean saveCaching = cachingDebugEntries;
			cachingDebugEntries = true;
			debug(LoggingLevel.ERROR, 'Exception: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
			cachingDebugEntries = saveCaching;


      //To-Do: uncomment it
			//insert new Log__c(Name = 'Exception', Text__c = debugEntriesToString().left(131000));
		}
	}

	public static void debug(LoggingLevel level, Object message) {
		if (debugging) {
			if (cachingDebugEntries) {
				debugEntries.add(new DebugEntry(DEBUG_PREFIX + message));
			} else {
				System.debug(level, DEBUG_PREFIX + message);
			}
		}
	}

	/** Assert a condition; throws on failure when debugging */
	public static void assert(Boolean condition) {
		assert(condition, null);
	}

	/** Assert equality; throws on failure when debugging */
	public static void assertEquals(Object v1, Object v2) {
		assert(v1 == v2, null);
	}

	/** Assert equality with a message; throws on failure when debugging */
	public static void assertEquals(Object v1, Object v2, Object message) {
		assert(v1 == v2, message);
	}

	/** Assert inequality; throws on failure when debugging */
	public static void assertNotEquals(Object v1, Object v2) {
		assert(v1 != v2, null);
	}

	/** Assert inequality with a message; throws on failure when debugging */
	public static void assertNotEquals(Object v1, Object v2, Object message) {
		assert(v1 != v2, message);
	}

	/** Assert a precondition with a message; throws on failure when debugging */
	public static void preCondition(Boolean condition, Object message) {
		assert(condition, 'preCondition failed: ' + message);
	}

	/** Assert a postcondition; throws on failure when debugging */
	public static void postCondition(Boolean condition, Object message) {
		assert(condition, 'postCondition failed: ' + message);
	}

	/** Assert an invariant; throws on failure when debugging */
	public static void invariant(Boolean condition, Object message) {
		assert(condition, 'invariant failed: ' + message);
	}

	/** Assert a condition; throws on failure when debugging*/
	public static void assert(Boolean condition, Object message) {
		if (debugging && !condition) {
			throw new AssertionException(String.valueOf(message));
		}
	}

	private static Boolean cachingDebugEntries = false;
	private static Integer debugEntryLevel = 0;

	/** A class for caching debug entires for later persistence */
	private class DebugEntry {
		public Integer level = debugEntryLevel;
		public String text;

		public DebugEntry(String text) {
			this.text = text;
		}
	}

	private static DebugEntry[] debugEntries = new DebugEntry[] { };

	@TestVisible private static String debugEntriesToString() {
		String result = '';
		for (DebugEntry e : debugEntries) {
			result += e.text.leftPad(e.level * 2 + e.text.length()) + '\n';
		}

		return result;
	}

}