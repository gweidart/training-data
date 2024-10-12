// Generated from /root/sol/solidity_parser/Solidity.g4 by ANTLR 4.13.1
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast", "CheckReturnValue"})
public class SolidityParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.13.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, T__1=2, T__2=3, T__3=4, T__4=5, T__5=6, T__6=7, T__7=8, T__8=9, 
		T__9=10, T__10=11, T__11=12, T__12=13, T__13=14, T__14=15, T__15=16, T__16=17, 
		T__17=18, T__18=19, T__19=20, T__20=21, T__21=22, T__22=23, T__23=24, 
		T__24=25, T__25=26, T__26=27, T__27=28, T__28=29, T__29=30, T__30=31, 
		T__31=32, T__32=33, T__33=34, T__34=35, T__35=36, T__36=37, T__37=38, 
		T__38=39, T__39=40, T__40=41, T__41=42, T__42=43, T__43=44, T__44=45, 
		T__45=46, T__46=47, T__47=48, T__48=49, T__49=50, T__50=51, T__51=52, 
		T__52=53, T__53=54, T__54=55, T__55=56, T__56=57, T__57=58, T__58=59, 
		T__59=60, T__60=61, T__61=62, T__62=63, T__63=64, T__64=65, T__65=66, 
		T__66=67, T__67=68, T__68=69, T__69=70, T__70=71, T__71=72, T__72=73, 
		T__73=74, T__74=75, T__75=76, T__76=77, T__77=78, T__78=79, T__79=80, 
		T__80=81, T__81=82, T__82=83, T__83=84, T__84=85, T__85=86, T__86=87, 
		T__87=88, T__88=89, T__89=90, T__90=91, T__91=92, T__92=93, T__93=94, 
		T__94=95, T__95=96, T__96=97, T__97=98, Int=99, Uint=100, Byte=101, Fixed=102, 
		Ufixed=103, BooleanLiteral=104, DecimalNumber=105, HexNumber=106, NumberUnit=107, 
		HexLiteralFragment=108, ReservedKeyword=109, AnonymousKeyword=110, BreakKeyword=111, 
		ConstantKeyword=112, ImmutableKeyword=113, ContinueKeyword=114, LeaveKeyword=115, 
		ExternalKeyword=116, IndexedKeyword=117, InternalKeyword=118, PayableKeyword=119, 
		PrivateKeyword=120, PublicKeyword=121, VirtualKeyword=122, PureKeyword=123, 
		TypeKeyword=124, ViewKeyword=125, ConstructorKeyword=126, FallbackKeyword=127, 
		ReceiveKeyword=128, Identifier=129, StringLiteralFragment=130, VersionLiteral=131, 
		WS=132, COMMENT=133, LINE_COMMENT=134;
	public static final int
		RULE_sourceUnit = 0, RULE_pragmaDirective = 1, RULE_pragmaName = 2, RULE_pragmaValue = 3, 
		RULE_version = 4, RULE_versionOperator = 5, RULE_versionConstraint = 6, 
		RULE_importDeclaration = 7, RULE_importDirective = 8, RULE_importPath = 9, 
		RULE_contractDefinition = 10, RULE_inheritanceSpecifier = 11, RULE_contractPart = 12, 
		RULE_stateVariableDeclaration = 13, RULE_fileLevelConstant = 14, RULE_customErrorDefinition = 15, 
		RULE_usingForDeclaration = 16, RULE_structDefinition = 17, RULE_modifierDefinition = 18, 
		RULE_modifierInvocation = 19, RULE_functionDefinition = 20, RULE_functionDescriptor = 21, 
		RULE_returnParameters = 22, RULE_modifierList = 23, RULE_eventDefinition = 24, 
		RULE_enumValue = 25, RULE_enumDefinition = 26, RULE_parameterList = 27, 
		RULE_parameter = 28, RULE_eventParameterList = 29, RULE_eventParameter = 30, 
		RULE_functionTypeParameterList = 31, RULE_functionTypeParameter = 32, 
		RULE_variableDeclaration = 33, RULE_typeName = 34, RULE_userDefinedTypeName = 35, 
		RULE_mappingKey = 36, RULE_mapping = 37, RULE_functionTypeName = 38, RULE_storageLocation = 39, 
		RULE_stateMutability = 40, RULE_block = 41, RULE_statement = 42, RULE_expressionStatement = 43, 
		RULE_ifStatement = 44, RULE_tryStatement = 45, RULE_catchClause = 46, 
		RULE_whileStatement = 47, RULE_simpleStatement = 48, RULE_uncheckedStatement = 49, 
		RULE_placeholderStatement = 50, RULE_forStatement = 51, RULE_inlineAssemblyStatement = 52, 
		RULE_doWhileStatement = 53, RULE_continueStatement = 54, RULE_breakStatement = 55, 
		RULE_returnStatement = 56, RULE_throwStatement = 57, RULE_emitStatement = 58, 
		RULE_revertStatement = 59, RULE_variableDeclarationStatement = 60, RULE_variableDeclarationList = 61, 
		RULE_identifierList = 62, RULE_elementaryTypeName = 63, RULE_expression = 64, 
		RULE_primaryExpression = 65, RULE_expressionList = 66, RULE_nameValueList = 67, 
		RULE_nameValue = 68, RULE_functionCallOptions = 69, RULE_functionCallArguments = 70, 
		RULE_functionCall = 71, RULE_assemblyBlock = 72, RULE_assemblyItem = 73, 
		RULE_assemblyExpression = 74, RULE_assemblyMember = 75, RULE_assemblyCall = 76, 
		RULE_assemblyLocalDefinition = 77, RULE_assemblyAssignment = 78, RULE_assemblyIdentifierOrList = 79, 
		RULE_assemblyIdentifierList = 80, RULE_assemblyStackAssignment = 81, RULE_labelDefinition = 82, 
		RULE_assemblySwitch = 83, RULE_assemblyCase = 84, RULE_assemblyFunctionDefinition = 85, 
		RULE_assemblyFunctionReturns = 86, RULE_assemblyFor = 87, RULE_assemblyIf = 88, 
		RULE_assemblyLiteral = 89, RULE_subAssembly = 90, RULE_tupleExpression = 91, 
		RULE_typeNameExpression = 92, RULE_numberLiteral = 93, RULE_identifier = 94, 
		RULE_hexLiteral = 95, RULE_visibilityKeyword = 96, RULE_allKeywords = 97, 
		RULE_overrideSpecifier = 98, RULE_stringLiteral = 99;
	private static String[] makeRuleNames() {
		return new String[] {
			"sourceUnit", "pragmaDirective", "pragmaName", "pragmaValue", "version", 
			"versionOperator", "versionConstraint", "importDeclaration", "importDirective", 
			"importPath", "contractDefinition", "inheritanceSpecifier", "contractPart", 
			"stateVariableDeclaration", "fileLevelConstant", "customErrorDefinition", 
			"usingForDeclaration", "structDefinition", "modifierDefinition", "modifierInvocation", 
			"functionDefinition", "functionDescriptor", "returnParameters", "modifierList", 
			"eventDefinition", "enumValue", "enumDefinition", "parameterList", "parameter", 
			"eventParameterList", "eventParameter", "functionTypeParameterList", 
			"functionTypeParameter", "variableDeclaration", "typeName", "userDefinedTypeName", 
			"mappingKey", "mapping", "functionTypeName", "storageLocation", "stateMutability", 
			"block", "statement", "expressionStatement", "ifStatement", "tryStatement", 
			"catchClause", "whileStatement", "simpleStatement", "uncheckedStatement", 
			"placeholderStatement", "forStatement", "inlineAssemblyStatement", "doWhileStatement", 
			"continueStatement", "breakStatement", "returnStatement", "throwStatement", 
			"emitStatement", "revertStatement", "variableDeclarationStatement", "variableDeclarationList", 
			"identifierList", "elementaryTypeName", "expression", "primaryExpression", 
			"expressionList", "nameValueList", "nameValue", "functionCallOptions", 
			"functionCallArguments", "functionCall", "assemblyBlock", "assemblyItem", 
			"assemblyExpression", "assemblyMember", "assemblyCall", "assemblyLocalDefinition", 
			"assemblyAssignment", "assemblyIdentifierOrList", "assemblyIdentifierList", 
			"assemblyStackAssignment", "labelDefinition", "assemblySwitch", "assemblyCase", 
			"assemblyFunctionDefinition", "assemblyFunctionReturns", "assemblyFor", 
			"assemblyIf", "assemblyLiteral", "subAssembly", "tupleExpression", "typeNameExpression", 
			"numberLiteral", "identifier", "hexLiteral", "visibilityKeyword", "allKeywords", 
			"overrideSpecifier", "stringLiteral"
		};
	}
	public static final String[] ruleNames = makeRuleNames();

	private static String[] makeLiteralNames() {
		return new String[] {
			null, "'pragma'", "';'", "'||'", "'^'", "'~'", "'>='", "'>'", "'<'", 
			"'<='", "'='", "'as'", "'import'", "'*'", "'from'", "'{'", "','", "'}'", 
			"'abstract'", "'contract'", "'interface'", "'library'", "'is'", "'('", 
			"')'", "'error'", "'using'", "'for'", "'struct'", "'modifier'", "'function'", 
			"'returns'", "'event'", "'enum'", "'['", "']'", "'address'", "'.'", "'mapping'", 
			"'=>'", "'memory'", "'storage'", "'calldata'", "'if'", "'else'", "'try'", 
			"'catch'", "'while'", "'unchecked'", "'_'", "'assembly'", "'do'", "'return'", 
			"'throw'", "'emit'", "'revert'", "'var'", "'bool'", "'string'", "'byte'", 
			"'++'", "'--'", "'new'", "':'", "'+'", "'-'", "'after'", "'delete'", 
			"'!'", "'**'", "'/'", "'%'", "'<<'", "'>>'", "'&'", "'|'", "'=='", "'!='", 
			"'&&'", "'?'", "'|='", "'^='", "'&='", "'<<='", "'>>='", "'+='", "'-='", 
			"'*='", "'/='", "'%='", "'let'", "':='", "'=:'", "'switch'", "'case'", 
			"'default'", "'->'", "'callback'", "'override'", null, null, null, null, 
			null, null, null, null, null, null, null, "'anonymous'", "'break'", "'constant'", 
			"'immutable'", "'continue'", "'leave'", "'external'", "'indexed'", "'internal'", 
			"'payable'", "'private'", "'public'", "'virtual'", "'pure'", "'type'", 
			"'view'", "'constructor'", "'fallback'", "'receive'"
		};
	}
	private static final String[] _LITERAL_NAMES = makeLiteralNames();
	private static String[] makeSymbolicNames() {
		return new String[] {
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, "Int", "Uint", "Byte", "Fixed", "Ufixed", "BooleanLiteral", 
			"DecimalNumber", "HexNumber", "NumberUnit", "HexLiteralFragment", "ReservedKeyword", 
			"AnonymousKeyword", "BreakKeyword", "ConstantKeyword", "ImmutableKeyword", 
			"ContinueKeyword", "LeaveKeyword", "ExternalKeyword", "IndexedKeyword", 
			"InternalKeyword", "PayableKeyword", "PrivateKeyword", "PublicKeyword", 
			"VirtualKeyword", "PureKeyword", "TypeKeyword", "ViewKeyword", "ConstructorKeyword", 
			"FallbackKeyword", "ReceiveKeyword", "Identifier", "StringLiteralFragment", 
			"VersionLiteral", "WS", "COMMENT", "LINE_COMMENT"
		};
	}
	private static final String[] _SYMBOLIC_NAMES = makeSymbolicNames();
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}

	@Override
	public String getGrammarFileName() { return "Solidity.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public SolidityParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@SuppressWarnings("CheckReturnValue")
	public static class SourceUnitContext extends ParserRuleContext {
		public TerminalNode EOF() { return getToken(SolidityParser.EOF, 0); }
		public List<PragmaDirectiveContext> pragmaDirective() {
			return getRuleContexts(PragmaDirectiveContext.class);
		}
		public PragmaDirectiveContext pragmaDirective(int i) {
			return getRuleContext(PragmaDirectiveContext.class,i);
		}
		public List<ImportDirectiveContext> importDirective() {
			return getRuleContexts(ImportDirectiveContext.class);
		}
		public ImportDirectiveContext importDirective(int i) {
			return getRuleContext(ImportDirectiveContext.class,i);
		}
		public List<ContractDefinitionContext> contractDefinition() {
			return getRuleContexts(ContractDefinitionContext.class);
		}
		public ContractDefinitionContext contractDefinition(int i) {
			return getRuleContext(ContractDefinitionContext.class,i);
		}
		public List<EnumDefinitionContext> enumDefinition() {
			return getRuleContexts(EnumDefinitionContext.class);
		}
		public EnumDefinitionContext enumDefinition(int i) {
			return getRuleContext(EnumDefinitionContext.class,i);
		}
		public List<StructDefinitionContext> structDefinition() {
			return getRuleContexts(StructDefinitionContext.class);
		}
		public StructDefinitionContext structDefinition(int i) {
			return getRuleContext(StructDefinitionContext.class,i);
		}
		public List<FunctionDefinitionContext> functionDefinition() {
			return getRuleContexts(FunctionDefinitionContext.class);
		}
		public FunctionDefinitionContext functionDefinition(int i) {
			return getRuleContext(FunctionDefinitionContext.class,i);
		}
		public List<FileLevelConstantContext> fileLevelConstant() {
			return getRuleContexts(FileLevelConstantContext.class);
		}
		public FileLevelConstantContext fileLevelConstant(int i) {
			return getRuleContext(FileLevelConstantContext.class,i);
		}
		public List<CustomErrorDefinitionContext> customErrorDefinition() {
			return getRuleContexts(CustomErrorDefinitionContext.class);
		}
		public CustomErrorDefinitionContext customErrorDefinition(int i) {
			return getRuleContext(CustomErrorDefinitionContext.class,i);
		}
		public SourceUnitContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_sourceUnit; }
	}

	public final SourceUnitContext sourceUnit() throws RecognitionException {
		SourceUnitContext _localctx = new SourceUnitContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_sourceUnit);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(210);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897459201396738L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
				{
				setState(208);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,0,_ctx) ) {
				case 1:
					{
					setState(200);
					pragmaDirective();
					}
					break;
				case 2:
					{
					setState(201);
					importDirective();
					}
					break;
				case 3:
					{
					setState(202);
					contractDefinition();
					}
					break;
				case 4:
					{
					setState(203);
					enumDefinition();
					}
					break;
				case 5:
					{
					setState(204);
					structDefinition();
					}
					break;
				case 6:
					{
					setState(205);
					functionDefinition();
					}
					break;
				case 7:
					{
					setState(206);
					fileLevelConstant();
					}
					break;
				case 8:
					{
					setState(207);
					customErrorDefinition();
					}
					break;
				}
				}
				setState(212);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(213);
			match(EOF);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class PragmaDirectiveContext extends ParserRuleContext {
		public PragmaNameContext pragmaName() {
			return getRuleContext(PragmaNameContext.class,0);
		}
		public PragmaValueContext pragmaValue() {
			return getRuleContext(PragmaValueContext.class,0);
		}
		public PragmaDirectiveContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_pragmaDirective; }
	}

	public final PragmaDirectiveContext pragmaDirective() throws RecognitionException {
		PragmaDirectiveContext _localctx = new PragmaDirectiveContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_pragmaDirective);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(215);
			match(T__0);
			setState(216);
			pragmaName();
			setState(217);
			pragmaValue();
			setState(218);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class PragmaNameContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public PragmaNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_pragmaName; }
	}

	public final PragmaNameContext pragmaName() throws RecognitionException {
		PragmaNameContext _localctx = new PragmaNameContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_pragmaName);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(220);
			identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class PragmaValueContext extends ParserRuleContext {
		public VersionContext version() {
			return getRuleContext(VersionContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public PragmaValueContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_pragmaValue; }
	}

	public final PragmaValueContext pragmaValue() throws RecognitionException {
		PragmaValueContext _localctx = new PragmaValueContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_pragmaValue);
		try {
			setState(224);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,2,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(222);
				version();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(223);
				expression(0);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VersionContext extends ParserRuleContext {
		public List<VersionConstraintContext> versionConstraint() {
			return getRuleContexts(VersionConstraintContext.class);
		}
		public VersionConstraintContext versionConstraint(int i) {
			return getRuleContext(VersionConstraintContext.class,i);
		}
		public VersionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_version; }
	}

	public final VersionContext version() throws RecognitionException {
		VersionContext _localctx = new VersionContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_version);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(226);
			versionConstraint();
			setState(233);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & 2040L) != 0) || _la==DecimalNumber || _la==VersionLiteral) {
				{
				{
				setState(228);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==T__2) {
					{
					setState(227);
					match(T__2);
					}
				}

				setState(230);
				versionConstraint();
				}
				}
				setState(235);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VersionOperatorContext extends ParserRuleContext {
		public VersionOperatorContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_versionOperator; }
	}

	public final VersionOperatorContext versionOperator() throws RecognitionException {
		VersionOperatorContext _localctx = new VersionOperatorContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_versionOperator);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(236);
			_la = _input.LA(1);
			if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & 2032L) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VersionConstraintContext extends ParserRuleContext {
		public TerminalNode VersionLiteral() { return getToken(SolidityParser.VersionLiteral, 0); }
		public VersionOperatorContext versionOperator() {
			return getRuleContext(VersionOperatorContext.class,0);
		}
		public TerminalNode DecimalNumber() { return getToken(SolidityParser.DecimalNumber, 0); }
		public VersionConstraintContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_versionConstraint; }
	}

	public final VersionConstraintContext versionConstraint() throws RecognitionException {
		VersionConstraintContext _localctx = new VersionConstraintContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_versionConstraint);
		int _la;
		try {
			setState(246);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,7,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(239);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 2032L) != 0)) {
					{
					setState(238);
					versionOperator();
					}
				}

				setState(241);
				match(VersionLiteral);
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(243);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 2032L) != 0)) {
					{
					setState(242);
					versionOperator();
					}
				}

				setState(245);
				match(DecimalNumber);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ImportDeclarationContext extends ParserRuleContext {
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public ImportDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_importDeclaration; }
	}

	public final ImportDeclarationContext importDeclaration() throws RecognitionException {
		ImportDeclarationContext _localctx = new ImportDeclarationContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_importDeclaration);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(248);
			identifier();
			setState(251);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__10) {
				{
				setState(249);
				match(T__10);
				setState(250);
				identifier();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ImportDirectiveContext extends ParserRuleContext {
		public ImportPathContext importPath() {
			return getRuleContext(ImportPathContext.class,0);
		}
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public List<ImportDeclarationContext> importDeclaration() {
			return getRuleContexts(ImportDeclarationContext.class);
		}
		public ImportDeclarationContext importDeclaration(int i) {
			return getRuleContext(ImportDeclarationContext.class,i);
		}
		public ImportDirectiveContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_importDirective; }
	}

	public final ImportDirectiveContext importDirective() throws RecognitionException {
		ImportDirectiveContext _localctx = new ImportDirectiveContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_importDirective);
		int _la;
		try {
			setState(289);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,13,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(253);
				match(T__11);
				setState(254);
				importPath();
				setState(257);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==T__10) {
					{
					setState(255);
					match(T__10);
					setState(256);
					identifier();
					}
				}

				setState(259);
				match(T__1);
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(261);
				match(T__11);
				setState(264);
				_errHandler.sync(this);
				switch (_input.LA(1)) {
				case T__12:
					{
					setState(262);
					match(T__12);
					}
					break;
				case T__13:
				case T__24:
				case T__41:
				case T__54:
				case T__96:
				case AnonymousKeyword:
				case BreakKeyword:
				case ConstantKeyword:
				case ImmutableKeyword:
				case ContinueKeyword:
				case LeaveKeyword:
				case ExternalKeyword:
				case IndexedKeyword:
				case InternalKeyword:
				case PayableKeyword:
				case PrivateKeyword:
				case PublicKeyword:
				case VirtualKeyword:
				case PureKeyword:
				case TypeKeyword:
				case ViewKeyword:
				case ConstructorKeyword:
				case FallbackKeyword:
				case ReceiveKeyword:
				case Identifier:
					{
					setState(263);
					identifier();
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				setState(268);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==T__10) {
					{
					setState(266);
					match(T__10);
					setState(267);
					identifier();
					}
				}

				setState(270);
				match(T__13);
				setState(271);
				importPath();
				setState(272);
				match(T__1);
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(274);
				match(T__11);
				setState(275);
				match(T__14);
				setState(276);
				importDeclaration();
				setState(281);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==T__15) {
					{
					{
					setState(277);
					match(T__15);
					setState(278);
					importDeclaration();
					}
					}
					setState(283);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				setState(284);
				match(T__16);
				setState(285);
				match(T__13);
				setState(286);
				importPath();
				setState(287);
				match(T__1);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ImportPathContext extends ParserRuleContext {
		public TerminalNode StringLiteralFragment() { return getToken(SolidityParser.StringLiteralFragment, 0); }
		public ImportPathContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_importPath; }
	}

	public final ImportPathContext importPath() throws RecognitionException {
		ImportPathContext _localctx = new ImportPathContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_importPath);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(291);
			match(StringLiteralFragment);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ContractDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<InheritanceSpecifierContext> inheritanceSpecifier() {
			return getRuleContexts(InheritanceSpecifierContext.class);
		}
		public InheritanceSpecifierContext inheritanceSpecifier(int i) {
			return getRuleContext(InheritanceSpecifierContext.class,i);
		}
		public List<ContractPartContext> contractPart() {
			return getRuleContexts(ContractPartContext.class);
		}
		public ContractPartContext contractPart(int i) {
			return getRuleContext(ContractPartContext.class,i);
		}
		public ContractDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_contractDefinition; }
	}

	public final ContractDefinitionContext contractDefinition() throws RecognitionException {
		ContractDefinitionContext _localctx = new ContractDefinitionContext(_ctx, getState());
		enterRule(_localctx, 20, RULE_contractDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(294);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__17) {
				{
				setState(293);
				match(T__17);
				}
			}

			setState(296);
			_la = _input.LA(1);
			if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & 3670016L) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			setState(297);
			identifier();
			setState(307);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__21) {
				{
				setState(298);
				match(T__21);
				setState(299);
				inheritanceSpecifier();
				setState(304);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==T__15) {
					{
					{
					setState(300);
					match(T__15);
					setState(301);
					inheritanceSpecifier();
					}
					}
					setState(306);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(309);
			match(T__14);
			setState(313);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897464096407552L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
				{
				{
				setState(310);
				contractPart();
				}
				}
				setState(315);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(316);
			match(T__16);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class InheritanceSpecifierContext extends ParserRuleContext {
		public UserDefinedTypeNameContext userDefinedTypeName() {
			return getRuleContext(UserDefinedTypeNameContext.class,0);
		}
		public ExpressionListContext expressionList() {
			return getRuleContext(ExpressionListContext.class,0);
		}
		public InheritanceSpecifierContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_inheritanceSpecifier; }
	}

	public final InheritanceSpecifierContext inheritanceSpecifier() throws RecognitionException {
		InheritanceSpecifierContext _localctx = new InheritanceSpecifierContext(_ctx, getState());
		enterRule(_localctx, 22, RULE_inheritanceSpecifier);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(318);
			userDefinedTypeName();
			setState(324);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__22) {
				{
				setState(319);
				match(T__22);
				setState(321);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
					{
					setState(320);
					expressionList();
					}
				}

				setState(323);
				match(T__23);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ContractPartContext extends ParserRuleContext {
		public StateVariableDeclarationContext stateVariableDeclaration() {
			return getRuleContext(StateVariableDeclarationContext.class,0);
		}
		public UsingForDeclarationContext usingForDeclaration() {
			return getRuleContext(UsingForDeclarationContext.class,0);
		}
		public StructDefinitionContext structDefinition() {
			return getRuleContext(StructDefinitionContext.class,0);
		}
		public ModifierDefinitionContext modifierDefinition() {
			return getRuleContext(ModifierDefinitionContext.class,0);
		}
		public FunctionDefinitionContext functionDefinition() {
			return getRuleContext(FunctionDefinitionContext.class,0);
		}
		public EventDefinitionContext eventDefinition() {
			return getRuleContext(EventDefinitionContext.class,0);
		}
		public EnumDefinitionContext enumDefinition() {
			return getRuleContext(EnumDefinitionContext.class,0);
		}
		public CustomErrorDefinitionContext customErrorDefinition() {
			return getRuleContext(CustomErrorDefinitionContext.class,0);
		}
		public ContractPartContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_contractPart; }
	}

	public final ContractPartContext contractPart() throws RecognitionException {
		ContractPartContext _localctx = new ContractPartContext(_ctx, getState());
		enterRule(_localctx, 24, RULE_contractPart);
		try {
			setState(334);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,20,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(326);
				stateVariableDeclaration();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(327);
				usingForDeclaration();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(328);
				structDefinition();
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(329);
				modifierDefinition();
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(330);
				functionDefinition();
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(331);
				eventDefinition();
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(332);
				enumDefinition();
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(333);
				customErrorDefinition();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StateVariableDeclarationContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<TerminalNode> PublicKeyword() { return getTokens(SolidityParser.PublicKeyword); }
		public TerminalNode PublicKeyword(int i) {
			return getToken(SolidityParser.PublicKeyword, i);
		}
		public List<TerminalNode> InternalKeyword() { return getTokens(SolidityParser.InternalKeyword); }
		public TerminalNode InternalKeyword(int i) {
			return getToken(SolidityParser.InternalKeyword, i);
		}
		public List<TerminalNode> PrivateKeyword() { return getTokens(SolidityParser.PrivateKeyword); }
		public TerminalNode PrivateKeyword(int i) {
			return getToken(SolidityParser.PrivateKeyword, i);
		}
		public List<TerminalNode> ConstantKeyword() { return getTokens(SolidityParser.ConstantKeyword); }
		public TerminalNode ConstantKeyword(int i) {
			return getToken(SolidityParser.ConstantKeyword, i);
		}
		public List<TerminalNode> ImmutableKeyword() { return getTokens(SolidityParser.ImmutableKeyword); }
		public TerminalNode ImmutableKeyword(int i) {
			return getToken(SolidityParser.ImmutableKeyword, i);
		}
		public List<OverrideSpecifierContext> overrideSpecifier() {
			return getRuleContexts(OverrideSpecifierContext.class);
		}
		public OverrideSpecifierContext overrideSpecifier(int i) {
			return getRuleContext(OverrideSpecifierContext.class,i);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public StateVariableDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_stateVariableDeclaration; }
	}

	public final StateVariableDeclarationContext stateVariableDeclaration() throws RecognitionException {
		StateVariableDeclarationContext _localctx = new StateVariableDeclarationContext(_ctx, getState());
		enterRule(_localctx, 26, RULE_stateVariableDeclaration);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(336);
			typeName(0);
			setState(345);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,22,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					setState(343);
					_errHandler.sync(this);
					switch (_input.LA(1)) {
					case PublicKeyword:
						{
						setState(337);
						match(PublicKeyword);
						}
						break;
					case InternalKeyword:
						{
						setState(338);
						match(InternalKeyword);
						}
						break;
					case PrivateKeyword:
						{
						setState(339);
						match(PrivateKeyword);
						}
						break;
					case ConstantKeyword:
						{
						setState(340);
						match(ConstantKeyword);
						}
						break;
					case ImmutableKeyword:
						{
						setState(341);
						match(ImmutableKeyword);
						}
						break;
					case T__97:
						{
						setState(342);
						overrideSpecifier();
						}
						break;
					default:
						throw new NoViableAltException(this);
					}
					} 
				}
				setState(347);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,22,_ctx);
			}
			setState(348);
			identifier();
			setState(351);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__9) {
				{
				setState(349);
				match(T__9);
				setState(350);
				expression(0);
				}
			}

			setState(353);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FileLevelConstantContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public TerminalNode ConstantKeyword() { return getToken(SolidityParser.ConstantKeyword, 0); }
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public FileLevelConstantContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_fileLevelConstant; }
	}

	public final FileLevelConstantContext fileLevelConstant() throws RecognitionException {
		FileLevelConstantContext _localctx = new FileLevelConstantContext(_ctx, getState());
		enterRule(_localctx, 28, RULE_fileLevelConstant);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(355);
			typeName(0);
			setState(356);
			match(ConstantKeyword);
			setState(357);
			identifier();
			setState(358);
			match(T__9);
			setState(359);
			expression(0);
			setState(360);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class CustomErrorDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public CustomErrorDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_customErrorDefinition; }
	}

	public final CustomErrorDefinitionContext customErrorDefinition() throws RecognitionException {
		CustomErrorDefinitionContext _localctx = new CustomErrorDefinitionContext(_ctx, getState());
		enterRule(_localctx, 30, RULE_customErrorDefinition);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(362);
			match(T__24);
			setState(363);
			identifier();
			setState(364);
			parameterList();
			setState(365);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class UsingForDeclarationContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public UsingForDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_usingForDeclaration; }
	}

	public final UsingForDeclarationContext usingForDeclaration() throws RecognitionException {
		UsingForDeclarationContext _localctx = new UsingForDeclarationContext(_ctx, getState());
		enterRule(_localctx, 32, RULE_usingForDeclaration);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(367);
			match(T__25);
			setState(368);
			identifier();
			setState(369);
			match(T__26);
			setState(372);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__12:
				{
				setState(370);
				match(T__12);
				}
				break;
			case T__13:
			case T__24:
			case T__29:
			case T__35:
			case T__37:
			case T__41:
			case T__54:
			case T__55:
			case T__56:
			case T__57:
			case T__58:
			case T__96:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
				{
				setState(371);
				typeName(0);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(374);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StructDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<VariableDeclarationContext> variableDeclaration() {
			return getRuleContexts(VariableDeclarationContext.class);
		}
		public VariableDeclarationContext variableDeclaration(int i) {
			return getRuleContext(VariableDeclarationContext.class,i);
		}
		public StructDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_structDefinition; }
	}

	public final StructDefinitionContext structDefinition() throws RecognitionException {
		StructDefinitionContext _localctx = new StructDefinitionContext(_ctx, getState());
		enterRule(_localctx, 34, RULE_structDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(376);
			match(T__27);
			setState(377);
			identifier();
			setState(378);
			match(T__14);
			setState(389);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897450339090432L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
				{
				setState(379);
				variableDeclaration();
				setState(380);
				match(T__1);
				setState(386);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897450339090432L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
					{
					{
					setState(381);
					variableDeclaration();
					setState(382);
					match(T__1);
					}
					}
					setState(388);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(391);
			match(T__16);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ModifierDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public List<TerminalNode> VirtualKeyword() { return getTokens(SolidityParser.VirtualKeyword); }
		public TerminalNode VirtualKeyword(int i) {
			return getToken(SolidityParser.VirtualKeyword, i);
		}
		public List<OverrideSpecifierContext> overrideSpecifier() {
			return getRuleContexts(OverrideSpecifierContext.class);
		}
		public OverrideSpecifierContext overrideSpecifier(int i) {
			return getRuleContext(OverrideSpecifierContext.class,i);
		}
		public ModifierDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_modifierDefinition; }
	}

	public final ModifierDefinitionContext modifierDefinition() throws RecognitionException {
		ModifierDefinitionContext _localctx = new ModifierDefinitionContext(_ctx, getState());
		enterRule(_localctx, 36, RULE_modifierDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(393);
			match(T__28);
			setState(394);
			identifier();
			setState(396);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__22) {
				{
				setState(395);
				parameterList();
				}
			}

			setState(402);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__97 || _la==VirtualKeyword) {
				{
				setState(400);
				_errHandler.sync(this);
				switch (_input.LA(1)) {
				case VirtualKeyword:
					{
					setState(398);
					match(VirtualKeyword);
					}
					break;
				case T__97:
					{
					setState(399);
					overrideSpecifier();
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				}
				setState(404);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(407);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__1:
				{
				setState(405);
				match(T__1);
				}
				break;
			case T__14:
				{
				setState(406);
				block();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ModifierInvocationContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ExpressionListContext expressionList() {
			return getRuleContext(ExpressionListContext.class,0);
		}
		public ModifierInvocationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_modifierInvocation; }
	}

	public final ModifierInvocationContext modifierInvocation() throws RecognitionException {
		ModifierInvocationContext _localctx = new ModifierInvocationContext(_ctx, getState());
		enterRule(_localctx, 38, RULE_modifierInvocation);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(409);
			identifier();
			setState(415);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__22) {
				{
				setState(410);
				match(T__22);
				setState(412);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
					{
					setState(411);
					expressionList();
					}
				}

				setState(414);
				match(T__23);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionDefinitionContext extends ParserRuleContext {
		public FunctionDescriptorContext functionDescriptor() {
			return getRuleContext(FunctionDescriptorContext.class,0);
		}
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public ModifierListContext modifierList() {
			return getRuleContext(ModifierListContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public ReturnParametersContext returnParameters() {
			return getRuleContext(ReturnParametersContext.class,0);
		}
		public FunctionDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionDefinition; }
	}

	public final FunctionDefinitionContext functionDefinition() throws RecognitionException {
		FunctionDefinitionContext _localctx = new FunctionDefinitionContext(_ctx, getState());
		enterRule(_localctx, 40, RULE_functionDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(417);
			functionDescriptor();
			setState(418);
			parameterList();
			setState(419);
			modifierList();
			setState(421);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__30) {
				{
				setState(420);
				returnParameters();
				}
			}

			setState(425);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__1:
				{
				setState(423);
				match(T__1);
				}
				break;
			case T__14:
				{
				setState(424);
				block();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionDescriptorContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public TerminalNode ConstructorKeyword() { return getToken(SolidityParser.ConstructorKeyword, 0); }
		public TerminalNode FallbackKeyword() { return getToken(SolidityParser.FallbackKeyword, 0); }
		public TerminalNode ReceiveKeyword() { return getToken(SolidityParser.ReceiveKeyword, 0); }
		public FunctionDescriptorContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionDescriptor; }
	}

	public final FunctionDescriptorContext functionDescriptor() throws RecognitionException {
		FunctionDescriptorContext _localctx = new FunctionDescriptorContext(_ctx, getState());
		enterRule(_localctx, 42, RULE_functionDescriptor);
		int _la;
		try {
			setState(434);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__29:
				enterOuterAlt(_localctx, 1);
				{
				setState(427);
				match(T__29);
				setState(429);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
					{
					setState(428);
					identifier();
					}
				}

				}
				break;
			case ConstructorKeyword:
				enterOuterAlt(_localctx, 2);
				{
				setState(431);
				match(ConstructorKeyword);
				}
				break;
			case FallbackKeyword:
				enterOuterAlt(_localctx, 3);
				{
				setState(432);
				match(FallbackKeyword);
				}
				break;
			case ReceiveKeyword:
				enterOuterAlt(_localctx, 4);
				{
				setState(433);
				match(ReceiveKeyword);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ReturnParametersContext extends ParserRuleContext {
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public ReturnParametersContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_returnParameters; }
	}

	public final ReturnParametersContext returnParameters() throws RecognitionException {
		ReturnParametersContext _localctx = new ReturnParametersContext(_ctx, getState());
		enterRule(_localctx, 44, RULE_returnParameters);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(436);
			match(T__30);
			setState(437);
			parameterList();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ModifierListContext extends ParserRuleContext {
		public List<VisibilityKeywordContext> visibilityKeyword() {
			return getRuleContexts(VisibilityKeywordContext.class);
		}
		public VisibilityKeywordContext visibilityKeyword(int i) {
			return getRuleContext(VisibilityKeywordContext.class,i);
		}
		public List<TerminalNode> VirtualKeyword() { return getTokens(SolidityParser.VirtualKeyword); }
		public TerminalNode VirtualKeyword(int i) {
			return getToken(SolidityParser.VirtualKeyword, i);
		}
		public List<StateMutabilityContext> stateMutability() {
			return getRuleContexts(StateMutabilityContext.class);
		}
		public StateMutabilityContext stateMutability(int i) {
			return getRuleContext(StateMutabilityContext.class,i);
		}
		public List<ModifierInvocationContext> modifierInvocation() {
			return getRuleContexts(ModifierInvocationContext.class);
		}
		public ModifierInvocationContext modifierInvocation(int i) {
			return getRuleContext(ModifierInvocationContext.class,i);
		}
		public List<OverrideSpecifierContext> overrideSpecifier() {
			return getRuleContexts(OverrideSpecifierContext.class);
		}
		public OverrideSpecifierContext overrideSpecifier(int i) {
			return getRuleContext(OverrideSpecifierContext.class,i);
		}
		public ModifierListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_modifierList; }
	}

	public final ModifierListContext modifierList() throws RecognitionException {
		ModifierListContext _localctx = new ModifierListContext(_ctx, getState());
		enterRule(_localctx, 46, RULE_modifierList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(446);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926403L) != 0)) {
				{
				setState(444);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,37,_ctx) ) {
				case 1:
					{
					setState(439);
					visibilityKeyword();
					}
					break;
				case 2:
					{
					setState(440);
					match(VirtualKeyword);
					}
					break;
				case 3:
					{
					setState(441);
					stateMutability();
					}
					break;
				case 4:
					{
					setState(442);
					modifierInvocation();
					}
					break;
				case 5:
					{
					setState(443);
					overrideSpecifier();
					}
					break;
				}
				}
				setState(448);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class EventDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public EventParameterListContext eventParameterList() {
			return getRuleContext(EventParameterListContext.class,0);
		}
		public TerminalNode AnonymousKeyword() { return getToken(SolidityParser.AnonymousKeyword, 0); }
		public EventDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventDefinition; }
	}

	public final EventDefinitionContext eventDefinition() throws RecognitionException {
		EventDefinitionContext _localctx = new EventDefinitionContext(_ctx, getState());
		enterRule(_localctx, 48, RULE_eventDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(449);
			match(T__31);
			setState(450);
			identifier();
			setState(451);
			eventParameterList();
			setState(453);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==AnonymousKeyword) {
				{
				setState(452);
				match(AnonymousKeyword);
				}
			}

			setState(455);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class EnumValueContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public EnumValueContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_enumValue; }
	}

	public final EnumValueContext enumValue() throws RecognitionException {
		EnumValueContext _localctx = new EnumValueContext(_ctx, getState());
		enterRule(_localctx, 50, RULE_enumValue);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(457);
			identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class EnumDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<EnumValueContext> enumValue() {
			return getRuleContexts(EnumValueContext.class);
		}
		public EnumValueContext enumValue(int i) {
			return getRuleContext(EnumValueContext.class,i);
		}
		public EnumDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_enumDefinition; }
	}

	public final EnumDefinitionContext enumDefinition() throws RecognitionException {
		EnumDefinitionContext _localctx = new EnumDefinitionContext(_ctx, getState());
		enterRule(_localctx, 52, RULE_enumDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(459);
			match(T__32);
			setState(460);
			identifier();
			setState(461);
			match(T__14);
			setState(463);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
				{
				setState(462);
				enumValue();
				}
			}

			setState(469);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__15) {
				{
				{
				setState(465);
				match(T__15);
				setState(466);
				enumValue();
				}
				}
				setState(471);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(472);
			match(T__16);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ParameterListContext extends ParserRuleContext {
		public List<ParameterContext> parameter() {
			return getRuleContexts(ParameterContext.class);
		}
		public ParameterContext parameter(int i) {
			return getRuleContext(ParameterContext.class,i);
		}
		public ParameterListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_parameterList; }
	}

	public final ParameterListContext parameterList() throws RecognitionException {
		ParameterListContext _localctx = new ParameterListContext(_ctx, getState());
		enterRule(_localctx, 54, RULE_parameterList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(474);
			match(T__22);
			setState(483);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897450339090432L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
				{
				setState(475);
				parameter();
				setState(480);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==T__15) {
					{
					{
					setState(476);
					match(T__15);
					setState(477);
					parameter();
					}
					}
					setState(482);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(485);
			match(T__23);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ParameterContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public StorageLocationContext storageLocation() {
			return getRuleContext(StorageLocationContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ParameterContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_parameter; }
	}

	public final ParameterContext parameter() throws RecognitionException {
		ParameterContext _localctx = new ParameterContext(_ctx, getState());
		enterRule(_localctx, 56, RULE_parameter);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(487);
			typeName(0);
			setState(489);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,44,_ctx) ) {
			case 1:
				{
				setState(488);
				storageLocation();
				}
				break;
			}
			setState(492);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
				{
				setState(491);
				identifier();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class EventParameterListContext extends ParserRuleContext {
		public List<EventParameterContext> eventParameter() {
			return getRuleContexts(EventParameterContext.class);
		}
		public EventParameterContext eventParameter(int i) {
			return getRuleContext(EventParameterContext.class,i);
		}
		public EventParameterListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventParameterList; }
	}

	public final EventParameterListContext eventParameterList() throws RecognitionException {
		EventParameterListContext _localctx = new EventParameterListContext(_ctx, getState());
		enterRule(_localctx, 58, RULE_eventParameterList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(494);
			match(T__22);
			setState(503);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897450339090432L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
				{
				setState(495);
				eventParameter();
				setState(500);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==T__15) {
					{
					{
					setState(496);
					match(T__15);
					setState(497);
					eventParameter();
					}
					}
					setState(502);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(505);
			match(T__23);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class EventParameterContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public TerminalNode IndexedKeyword() { return getToken(SolidityParser.IndexedKeyword, 0); }
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public EventParameterContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventParameter; }
	}

	public final EventParameterContext eventParameter() throws RecognitionException {
		EventParameterContext _localctx = new EventParameterContext(_ctx, getState());
		enterRule(_localctx, 60, RULE_eventParameter);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(507);
			typeName(0);
			setState(509);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,48,_ctx) ) {
			case 1:
				{
				setState(508);
				match(IndexedKeyword);
				}
				break;
			}
			setState(512);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
				{
				setState(511);
				identifier();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionTypeParameterListContext extends ParserRuleContext {
		public List<FunctionTypeParameterContext> functionTypeParameter() {
			return getRuleContexts(FunctionTypeParameterContext.class);
		}
		public FunctionTypeParameterContext functionTypeParameter(int i) {
			return getRuleContext(FunctionTypeParameterContext.class,i);
		}
		public FunctionTypeParameterListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionTypeParameterList; }
	}

	public final FunctionTypeParameterListContext functionTypeParameterList() throws RecognitionException {
		FunctionTypeParameterListContext _localctx = new FunctionTypeParameterListContext(_ctx, getState());
		enterRule(_localctx, 62, RULE_functionTypeParameterList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(514);
			match(T__22);
			setState(523);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897450339090432L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
				{
				setState(515);
				functionTypeParameter();
				setState(520);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==T__15) {
					{
					{
					setState(516);
					match(T__15);
					setState(517);
					functionTypeParameter();
					}
					}
					setState(522);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(525);
			match(T__23);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionTypeParameterContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public StorageLocationContext storageLocation() {
			return getRuleContext(StorageLocationContext.class,0);
		}
		public FunctionTypeParameterContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionTypeParameter; }
	}

	public final FunctionTypeParameterContext functionTypeParameter() throws RecognitionException {
		FunctionTypeParameterContext _localctx = new FunctionTypeParameterContext(_ctx, getState());
		enterRule(_localctx, 64, RULE_functionTypeParameter);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(527);
			typeName(0);
			setState(529);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 7696581394432L) != 0)) {
				{
				setState(528);
				storageLocation();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VariableDeclarationContext extends ParserRuleContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public StorageLocationContext storageLocation() {
			return getRuleContext(StorageLocationContext.class,0);
		}
		public VariableDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableDeclaration; }
	}

	public final VariableDeclarationContext variableDeclaration() throws RecognitionException {
		VariableDeclarationContext _localctx = new VariableDeclarationContext(_ctx, getState());
		enterRule(_localctx, 66, RULE_variableDeclaration);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(531);
			typeName(0);
			setState(533);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,53,_ctx) ) {
			case 1:
				{
				setState(532);
				storageLocation();
				}
				break;
			}
			setState(535);
			identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class TypeNameContext extends ParserRuleContext {
		public ElementaryTypeNameContext elementaryTypeName() {
			return getRuleContext(ElementaryTypeNameContext.class,0);
		}
		public UserDefinedTypeNameContext userDefinedTypeName() {
			return getRuleContext(UserDefinedTypeNameContext.class,0);
		}
		public MappingContext mapping() {
			return getRuleContext(MappingContext.class,0);
		}
		public FunctionTypeNameContext functionTypeName() {
			return getRuleContext(FunctionTypeNameContext.class,0);
		}
		public TerminalNode PayableKeyword() { return getToken(SolidityParser.PayableKeyword, 0); }
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public TypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_typeName; }
	}

	public final TypeNameContext typeName() throws RecognitionException {
		return typeName(0);
	}

	private TypeNameContext typeName(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		TypeNameContext _localctx = new TypeNameContext(_ctx, _parentState);
		TypeNameContext _prevctx = _localctx;
		int _startState = 68;
		enterRecursionRule(_localctx, 68, RULE_typeName, _p);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(544);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,54,_ctx) ) {
			case 1:
				{
				setState(538);
				elementaryTypeName();
				}
				break;
			case 2:
				{
				setState(539);
				userDefinedTypeName();
				}
				break;
			case 3:
				{
				setState(540);
				mapping();
				}
				break;
			case 4:
				{
				setState(541);
				functionTypeName();
				}
				break;
			case 5:
				{
				setState(542);
				match(T__35);
				setState(543);
				match(PayableKeyword);
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(554);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,56,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new TypeNameContext(_parentctx, _parentState);
					pushNewRecursionContext(_localctx, _startState, RULE_typeName);
					setState(546);
					if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
					setState(547);
					match(T__33);
					setState(549);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
						{
						setState(548);
						expression(0);
						}
					}

					setState(551);
					match(T__34);
					}
					} 
				}
				setState(556);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,56,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class UserDefinedTypeNameContext extends ParserRuleContext {
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public UserDefinedTypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_userDefinedTypeName; }
	}

	public final UserDefinedTypeNameContext userDefinedTypeName() throws RecognitionException {
		UserDefinedTypeNameContext _localctx = new UserDefinedTypeNameContext(_ctx, getState());
		enterRule(_localctx, 70, RULE_userDefinedTypeName);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(557);
			identifier();
			setState(562);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,57,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(558);
					match(T__36);
					setState(559);
					identifier();
					}
					} 
				}
				setState(564);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,57,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class MappingKeyContext extends ParserRuleContext {
		public ElementaryTypeNameContext elementaryTypeName() {
			return getRuleContext(ElementaryTypeNameContext.class,0);
		}
		public UserDefinedTypeNameContext userDefinedTypeName() {
			return getRuleContext(UserDefinedTypeNameContext.class,0);
		}
		public MappingKeyContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_mappingKey; }
	}

	public final MappingKeyContext mappingKey() throws RecognitionException {
		MappingKeyContext _localctx = new MappingKeyContext(_ctx, getState());
		enterRule(_localctx, 72, RULE_mappingKey);
		try {
			setState(567);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__35:
			case T__55:
			case T__56:
			case T__57:
			case T__58:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
				enterOuterAlt(_localctx, 1);
				{
				setState(565);
				elementaryTypeName();
				}
				break;
			case T__13:
			case T__24:
			case T__41:
			case T__54:
			case T__96:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
				enterOuterAlt(_localctx, 2);
				{
				setState(566);
				userDefinedTypeName();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class MappingContext extends ParserRuleContext {
		public MappingKeyContext mappingKey() {
			return getRuleContext(MappingKeyContext.class,0);
		}
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public MappingContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_mapping; }
	}

	public final MappingContext mapping() throws RecognitionException {
		MappingContext _localctx = new MappingContext(_ctx, getState());
		enterRule(_localctx, 74, RULE_mapping);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(569);
			match(T__37);
			setState(570);
			match(T__22);
			setState(571);
			mappingKey();
			setState(572);
			match(T__38);
			setState(573);
			typeName(0);
			setState(574);
			match(T__23);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionTypeNameContext extends ParserRuleContext {
		public List<FunctionTypeParameterListContext> functionTypeParameterList() {
			return getRuleContexts(FunctionTypeParameterListContext.class);
		}
		public FunctionTypeParameterListContext functionTypeParameterList(int i) {
			return getRuleContext(FunctionTypeParameterListContext.class,i);
		}
		public List<TerminalNode> InternalKeyword() { return getTokens(SolidityParser.InternalKeyword); }
		public TerminalNode InternalKeyword(int i) {
			return getToken(SolidityParser.InternalKeyword, i);
		}
		public List<TerminalNode> ExternalKeyword() { return getTokens(SolidityParser.ExternalKeyword); }
		public TerminalNode ExternalKeyword(int i) {
			return getToken(SolidityParser.ExternalKeyword, i);
		}
		public List<StateMutabilityContext> stateMutability() {
			return getRuleContexts(StateMutabilityContext.class);
		}
		public StateMutabilityContext stateMutability(int i) {
			return getRuleContext(StateMutabilityContext.class,i);
		}
		public FunctionTypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionTypeName; }
	}

	public final FunctionTypeNameContext functionTypeName() throws RecognitionException {
		FunctionTypeNameContext _localctx = new FunctionTypeNameContext(_ctx, getState());
		enterRule(_localctx, 76, RULE_functionTypeName);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(576);
			match(T__29);
			setState(577);
			functionTypeParameterList();
			setState(583);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,60,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					setState(581);
					_errHandler.sync(this);
					switch (_input.LA(1)) {
					case InternalKeyword:
						{
						setState(578);
						match(InternalKeyword);
						}
						break;
					case ExternalKeyword:
						{
						setState(579);
						match(ExternalKeyword);
						}
						break;
					case ConstantKeyword:
					case PayableKeyword:
					case PureKeyword:
					case ViewKeyword:
						{
						setState(580);
						stateMutability();
						}
						break;
					default:
						throw new NoViableAltException(this);
					}
					} 
				}
				setState(585);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,60,_ctx);
			}
			setState(588);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,61,_ctx) ) {
			case 1:
				{
				setState(586);
				match(T__30);
				setState(587);
				functionTypeParameterList();
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StorageLocationContext extends ParserRuleContext {
		public StorageLocationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_storageLocation; }
	}

	public final StorageLocationContext storageLocation() throws RecognitionException {
		StorageLocationContext _localctx = new StorageLocationContext(_ctx, getState());
		enterRule(_localctx, 78, RULE_storageLocation);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(590);
			_la = _input.LA(1);
			if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & 7696581394432L) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StateMutabilityContext extends ParserRuleContext {
		public TerminalNode PureKeyword() { return getToken(SolidityParser.PureKeyword, 0); }
		public TerminalNode ConstantKeyword() { return getToken(SolidityParser.ConstantKeyword, 0); }
		public TerminalNode ViewKeyword() { return getToken(SolidityParser.ViewKeyword, 0); }
		public TerminalNode PayableKeyword() { return getToken(SolidityParser.PayableKeyword, 0); }
		public StateMutabilityContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_stateMutability; }
	}

	public final StateMutabilityContext stateMutability() throws RecognitionException {
		StateMutabilityContext _localctx = new StateMutabilityContext(_ctx, getState());
		enterRule(_localctx, 80, RULE_stateMutability);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(592);
			_la = _input.LA(1);
			if ( !(((((_la - 112)) & ~0x3f) == 0 && ((1L << (_la - 112)) & 10369L) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class BlockContext extends ParserRuleContext {
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public BlockContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_block; }
	}

	public final BlockContext block() throws RecognitionException {
		BlockContext _localctx = new BlockContext(_ctx, getState());
		enterRule(_localctx, 82, RULE_block);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(594);
			match(T__14);
			setState(598);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -288233251056384511L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
				{
				{
				setState(595);
				statement();
				}
				}
				setState(600);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(601);
			match(T__16);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StatementContext extends ParserRuleContext {
		public IfStatementContext ifStatement() {
			return getRuleContext(IfStatementContext.class,0);
		}
		public TryStatementContext tryStatement() {
			return getRuleContext(TryStatementContext.class,0);
		}
		public WhileStatementContext whileStatement() {
			return getRuleContext(WhileStatementContext.class,0);
		}
		public ForStatementContext forStatement() {
			return getRuleContext(ForStatementContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public PlaceholderStatementContext placeholderStatement() {
			return getRuleContext(PlaceholderStatementContext.class,0);
		}
		public InlineAssemblyStatementContext inlineAssemblyStatement() {
			return getRuleContext(InlineAssemblyStatementContext.class,0);
		}
		public DoWhileStatementContext doWhileStatement() {
			return getRuleContext(DoWhileStatementContext.class,0);
		}
		public ContinueStatementContext continueStatement() {
			return getRuleContext(ContinueStatementContext.class,0);
		}
		public BreakStatementContext breakStatement() {
			return getRuleContext(BreakStatementContext.class,0);
		}
		public ReturnStatementContext returnStatement() {
			return getRuleContext(ReturnStatementContext.class,0);
		}
		public ThrowStatementContext throwStatement() {
			return getRuleContext(ThrowStatementContext.class,0);
		}
		public EmitStatementContext emitStatement() {
			return getRuleContext(EmitStatementContext.class,0);
		}
		public SimpleStatementContext simpleStatement() {
			return getRuleContext(SimpleStatementContext.class,0);
		}
		public UncheckedStatementContext uncheckedStatement() {
			return getRuleContext(UncheckedStatementContext.class,0);
		}
		public RevertStatementContext revertStatement() {
			return getRuleContext(RevertStatementContext.class,0);
		}
		public StatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statement; }
	}

	public final StatementContext statement() throws RecognitionException {
		StatementContext _localctx = new StatementContext(_ctx, getState());
		enterRule(_localctx, 84, RULE_statement);
		try {
			setState(619);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,63,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(603);
				ifStatement();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(604);
				tryStatement();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(605);
				whileStatement();
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(606);
				forStatement();
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(607);
				block();
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(608);
				placeholderStatement();
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(609);
				inlineAssemblyStatement();
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(610);
				doWhileStatement();
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(611);
				continueStatement();
				}
				break;
			case 10:
				enterOuterAlt(_localctx, 10);
				{
				setState(612);
				breakStatement();
				}
				break;
			case 11:
				enterOuterAlt(_localctx, 11);
				{
				setState(613);
				returnStatement();
				}
				break;
			case 12:
				enterOuterAlt(_localctx, 12);
				{
				setState(614);
				throwStatement();
				}
				break;
			case 13:
				enterOuterAlt(_localctx, 13);
				{
				setState(615);
				emitStatement();
				}
				break;
			case 14:
				enterOuterAlt(_localctx, 14);
				{
				setState(616);
				simpleStatement();
				}
				break;
			case 15:
				enterOuterAlt(_localctx, 15);
				{
				setState(617);
				uncheckedStatement();
				}
				break;
			case 16:
				enterOuterAlt(_localctx, 16);
				{
				setState(618);
				revertStatement();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ExpressionStatementContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ExpressionStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expressionStatement; }
	}

	public final ExpressionStatementContext expressionStatement() throws RecognitionException {
		ExpressionStatementContext _localctx = new ExpressionStatementContext(_ctx, getState());
		enterRule(_localctx, 86, RULE_expressionStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(621);
			expression(0);
			setState(622);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class IfStatementContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public IfStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_ifStatement; }
	}

	public final IfStatementContext ifStatement() throws RecognitionException {
		IfStatementContext _localctx = new IfStatementContext(_ctx, getState());
		enterRule(_localctx, 88, RULE_ifStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(624);
			match(T__42);
			setState(625);
			match(T__22);
			setState(626);
			expression(0);
			setState(627);
			match(T__23);
			setState(628);
			statement();
			setState(631);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,64,_ctx) ) {
			case 1:
				{
				setState(629);
				match(T__43);
				setState(630);
				statement();
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class TryStatementContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public ReturnParametersContext returnParameters() {
			return getRuleContext(ReturnParametersContext.class,0);
		}
		public List<CatchClauseContext> catchClause() {
			return getRuleContexts(CatchClauseContext.class);
		}
		public CatchClauseContext catchClause(int i) {
			return getRuleContext(CatchClauseContext.class,i);
		}
		public TryStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_tryStatement; }
	}

	public final TryStatementContext tryStatement() throws RecognitionException {
		TryStatementContext _localctx = new TryStatementContext(_ctx, getState());
		enterRule(_localctx, 90, RULE_tryStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(633);
			match(T__44);
			setState(634);
			expression(0);
			setState(636);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__30) {
				{
				setState(635);
				returnParameters();
				}
			}

			setState(638);
			block();
			setState(640); 
			_errHandler.sync(this);
			_la = _input.LA(1);
			do {
				{
				{
				setState(639);
				catchClause();
				}
				}
				setState(642); 
				_errHandler.sync(this);
				_la = _input.LA(1);
			} while ( _la==T__45 );
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class CatchClauseContext extends ParserRuleContext {
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public CatchClauseContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_catchClause; }
	}

	public final CatchClauseContext catchClause() throws RecognitionException {
		CatchClauseContext _localctx = new CatchClauseContext(_ctx, getState());
		enterRule(_localctx, 92, RULE_catchClause);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(644);
			match(T__45);
			setState(649);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195107434496L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
				{
				setState(646);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
					{
					setState(645);
					identifier();
					}
				}

				setState(648);
				parameterList();
				}
			}

			setState(651);
			block();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class WhileStatementContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public WhileStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_whileStatement; }
	}

	public final WhileStatementContext whileStatement() throws RecognitionException {
		WhileStatementContext _localctx = new WhileStatementContext(_ctx, getState());
		enterRule(_localctx, 94, RULE_whileStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(653);
			match(T__46);
			setState(654);
			match(T__22);
			setState(655);
			expression(0);
			setState(656);
			match(T__23);
			setState(657);
			statement();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class SimpleStatementContext extends ParserRuleContext {
		public VariableDeclarationStatementContext variableDeclarationStatement() {
			return getRuleContext(VariableDeclarationStatementContext.class,0);
		}
		public ExpressionStatementContext expressionStatement() {
			return getRuleContext(ExpressionStatementContext.class,0);
		}
		public SimpleStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_simpleStatement; }
	}

	public final SimpleStatementContext simpleStatement() throws RecognitionException {
		SimpleStatementContext _localctx = new SimpleStatementContext(_ctx, getState());
		enterRule(_localctx, 96, RULE_simpleStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(661);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,69,_ctx) ) {
			case 1:
				{
				setState(659);
				variableDeclarationStatement();
				}
				break;
			case 2:
				{
				setState(660);
				expressionStatement();
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class UncheckedStatementContext extends ParserRuleContext {
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public UncheckedStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_uncheckedStatement; }
	}

	public final UncheckedStatementContext uncheckedStatement() throws RecognitionException {
		UncheckedStatementContext _localctx = new UncheckedStatementContext(_ctx, getState());
		enterRule(_localctx, 98, RULE_uncheckedStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(663);
			match(T__47);
			setState(664);
			block();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class PlaceholderStatementContext extends ParserRuleContext {
		public PlaceholderStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_placeholderStatement; }
	}

	public final PlaceholderStatementContext placeholderStatement() throws RecognitionException {
		PlaceholderStatementContext _localctx = new PlaceholderStatementContext(_ctx, getState());
		enterRule(_localctx, 100, RULE_placeholderStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(666);
			match(T__48);
			setState(668);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__1) {
				{
				setState(667);
				match(T__1);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ForStatementContext extends ParserRuleContext {
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public SimpleStatementContext simpleStatement() {
			return getRuleContext(SimpleStatementContext.class,0);
		}
		public ExpressionStatementContext expressionStatement() {
			return getRuleContext(ExpressionStatementContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ForStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_forStatement; }
	}

	public final ForStatementContext forStatement() throws RecognitionException {
		ForStatementContext _localctx = new ForStatementContext(_ctx, getState());
		enterRule(_localctx, 102, RULE_forStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(670);
			match(T__26);
			setState(671);
			match(T__22);
			setState(674);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__4:
			case T__13:
			case T__22:
			case T__24:
			case T__29:
			case T__33:
			case T__35:
			case T__37:
			case T__41:
			case T__54:
			case T__55:
			case T__56:
			case T__57:
			case T__58:
			case T__59:
			case T__60:
			case T__61:
			case T__63:
			case T__64:
			case T__65:
			case T__66:
			case T__67:
			case T__96:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case BooleanLiteral:
			case DecimalNumber:
			case HexNumber:
			case HexLiteralFragment:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
			case StringLiteralFragment:
				{
				setState(672);
				simpleStatement();
				}
				break;
			case T__1:
				{
				setState(673);
				match(T__1);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(678);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__4:
			case T__13:
			case T__22:
			case T__24:
			case T__33:
			case T__35:
			case T__41:
			case T__54:
			case T__55:
			case T__56:
			case T__57:
			case T__58:
			case T__59:
			case T__60:
			case T__61:
			case T__63:
			case T__64:
			case T__65:
			case T__66:
			case T__67:
			case T__96:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case BooleanLiteral:
			case DecimalNumber:
			case HexNumber:
			case HexLiteralFragment:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
			case StringLiteralFragment:
				{
				setState(676);
				expressionStatement();
				}
				break;
			case T__1:
				{
				setState(677);
				match(T__1);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(681);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
				{
				setState(680);
				expression(0);
				}
			}

			setState(683);
			match(T__23);
			setState(684);
			statement();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class InlineAssemblyStatementContext extends ParserRuleContext {
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public TerminalNode StringLiteralFragment() { return getToken(SolidityParser.StringLiteralFragment, 0); }
		public InlineAssemblyStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_inlineAssemblyStatement; }
	}

	public final InlineAssemblyStatementContext inlineAssemblyStatement() throws RecognitionException {
		InlineAssemblyStatementContext _localctx = new InlineAssemblyStatementContext(_ctx, getState());
		enterRule(_localctx, 104, RULE_inlineAssemblyStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(686);
			match(T__49);
			setState(688);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==StringLiteralFragment) {
				{
				setState(687);
				match(StringLiteralFragment);
				}
			}

			setState(690);
			assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class DoWhileStatementContext extends ParserRuleContext {
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public DoWhileStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_doWhileStatement; }
	}

	public final DoWhileStatementContext doWhileStatement() throws RecognitionException {
		DoWhileStatementContext _localctx = new DoWhileStatementContext(_ctx, getState());
		enterRule(_localctx, 106, RULE_doWhileStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(692);
			match(T__50);
			setState(693);
			statement();
			setState(694);
			match(T__46);
			setState(695);
			match(T__22);
			setState(696);
			expression(0);
			setState(697);
			match(T__23);
			setState(698);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ContinueStatementContext extends ParserRuleContext {
		public TerminalNode ContinueKeyword() { return getToken(SolidityParser.ContinueKeyword, 0); }
		public ContinueStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_continueStatement; }
	}

	public final ContinueStatementContext continueStatement() throws RecognitionException {
		ContinueStatementContext _localctx = new ContinueStatementContext(_ctx, getState());
		enterRule(_localctx, 108, RULE_continueStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(700);
			match(ContinueKeyword);
			setState(701);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class BreakStatementContext extends ParserRuleContext {
		public TerminalNode BreakKeyword() { return getToken(SolidityParser.BreakKeyword, 0); }
		public BreakStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_breakStatement; }
	}

	public final BreakStatementContext breakStatement() throws RecognitionException {
		BreakStatementContext _localctx = new BreakStatementContext(_ctx, getState());
		enterRule(_localctx, 110, RULE_breakStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(703);
			match(BreakKeyword);
			setState(704);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ReturnStatementContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ReturnStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_returnStatement; }
	}

	public final ReturnStatementContext returnStatement() throws RecognitionException {
		ReturnStatementContext _localctx = new ReturnStatementContext(_ctx, getState());
		enterRule(_localctx, 112, RULE_returnStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(706);
			match(T__51);
			setState(708);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
				{
				setState(707);
				expression(0);
				}
			}

			setState(710);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ThrowStatementContext extends ParserRuleContext {
		public ThrowStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_throwStatement; }
	}

	public final ThrowStatementContext throwStatement() throws RecognitionException {
		ThrowStatementContext _localctx = new ThrowStatementContext(_ctx, getState());
		enterRule(_localctx, 114, RULE_throwStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(712);
			match(T__52);
			setState(713);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class EmitStatementContext extends ParserRuleContext {
		public FunctionCallContext functionCall() {
			return getRuleContext(FunctionCallContext.class,0);
		}
		public EmitStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_emitStatement; }
	}

	public final EmitStatementContext emitStatement() throws RecognitionException {
		EmitStatementContext _localctx = new EmitStatementContext(_ctx, getState());
		enterRule(_localctx, 116, RULE_emitStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(715);
			match(T__53);
			setState(716);
			functionCall();
			setState(717);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class RevertStatementContext extends ParserRuleContext {
		public FunctionCallContext functionCall() {
			return getRuleContext(FunctionCallContext.class,0);
		}
		public RevertStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_revertStatement; }
	}

	public final RevertStatementContext revertStatement() throws RecognitionException {
		RevertStatementContext _localctx = new RevertStatementContext(_ctx, getState());
		enterRule(_localctx, 118, RULE_revertStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(719);
			match(T__54);
			setState(720);
			functionCall();
			setState(721);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VariableDeclarationStatementContext extends ParserRuleContext {
		public IdentifierListContext identifierList() {
			return getRuleContext(IdentifierListContext.class,0);
		}
		public VariableDeclarationContext variableDeclaration() {
			return getRuleContext(VariableDeclarationContext.class,0);
		}
		public VariableDeclarationListContext variableDeclarationList() {
			return getRuleContext(VariableDeclarationListContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public VariableDeclarationStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableDeclarationStatement; }
	}

	public final VariableDeclarationStatementContext variableDeclarationStatement() throws RecognitionException {
		VariableDeclarationStatementContext _localctx = new VariableDeclarationStatementContext(_ctx, getState());
		enterRule(_localctx, 120, RULE_variableDeclarationStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(730);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,76,_ctx) ) {
			case 1:
				{
				setState(723);
				match(T__55);
				setState(724);
				identifierList();
				}
				break;
			case 2:
				{
				setState(725);
				variableDeclaration();
				}
				break;
			case 3:
				{
				setState(726);
				match(T__22);
				setState(727);
				variableDeclarationList();
				setState(728);
				match(T__23);
				}
				break;
			}
			setState(734);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__9) {
				{
				setState(732);
				match(T__9);
				setState(733);
				expression(0);
				}
			}

			setState(736);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VariableDeclarationListContext extends ParserRuleContext {
		public List<VariableDeclarationContext> variableDeclaration() {
			return getRuleContexts(VariableDeclarationContext.class);
		}
		public VariableDeclarationContext variableDeclaration(int i) {
			return getRuleContext(VariableDeclarationContext.class,i);
		}
		public VariableDeclarationListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableDeclarationList; }
	}

	public final VariableDeclarationListContext variableDeclarationList() throws RecognitionException {
		VariableDeclarationListContext _localctx = new VariableDeclarationListContext(_ctx, getState());
		enterRule(_localctx, 122, RULE_variableDeclarationList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(739);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897450339090432L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
				{
				setState(738);
				variableDeclaration();
				}
			}

			setState(747);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__15) {
				{
				{
				setState(741);
				match(T__15);
				setState(743);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 1116897450339090432L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926525L) != 0)) {
					{
					setState(742);
					variableDeclaration();
					}
				}

				}
				}
				setState(749);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class IdentifierListContext extends ParserRuleContext {
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public IdentifierListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_identifierList; }
	}

	public final IdentifierListContext identifierList() throws RecognitionException {
		IdentifierListContext _localctx = new IdentifierListContext(_ctx, getState());
		enterRule(_localctx, 124, RULE_identifierList);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(750);
			match(T__22);
			setState(757);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,82,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(752);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
						{
						setState(751);
						identifier();
						}
					}

					setState(754);
					match(T__15);
					}
					} 
				}
				setState(759);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,82,_ctx);
			}
			setState(761);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
				{
				setState(760);
				identifier();
				}
			}

			setState(763);
			match(T__23);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ElementaryTypeNameContext extends ParserRuleContext {
		public TerminalNode Int() { return getToken(SolidityParser.Int, 0); }
		public TerminalNode Uint() { return getToken(SolidityParser.Uint, 0); }
		public TerminalNode Byte() { return getToken(SolidityParser.Byte, 0); }
		public TerminalNode Fixed() { return getToken(SolidityParser.Fixed, 0); }
		public TerminalNode Ufixed() { return getToken(SolidityParser.Ufixed, 0); }
		public ElementaryTypeNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_elementaryTypeName; }
	}

	public final ElementaryTypeNameContext elementaryTypeName() throws RecognitionException {
		ElementaryTypeNameContext _localctx = new ElementaryTypeNameContext(_ctx, getState());
		enterRule(_localctx, 126, RULE_elementaryTypeName);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(765);
			_la = _input.LA(1);
			if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & 1080863979288395776L) != 0) || ((((_la - 99)) & ~0x3f) == 0 && ((1L << (_la - 99)) & 31L) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ExpressionContext extends ParserRuleContext {
		public ExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expression; }
	 
		public ExpressionContext() { }
		public void copyFrom(ExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}
	@SuppressWarnings("CheckReturnValue")
	public static class PrefixOperationContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public PrefixOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class KeywordPrefixOperationContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public KeywordPrefixOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class UnaryPrefixOperationContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public UnaryPrefixOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class OrderComparisonContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public OrderComparisonContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class ConditionalContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public ConditionalContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class AddOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public AddOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class AssignmentContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public AssignmentContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class TypeConversionContext extends ExpressionContext {
		public ElementaryTypeNameContext elementaryTypeName() {
			return getRuleContext(ElementaryTypeNameContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public TypeConversionContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class ShiftOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public ShiftOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class PrimaryContext extends ExpressionContext {
		public PrimaryExpressionContext primaryExpression() {
			return getRuleContext(PrimaryExpressionContext.class,0);
		}
		public PrimaryContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class BitAndOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public BitAndOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class MulOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public MulOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class IndexRangeAccessContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public IndexRangeAccessContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class PayableExpressionContext extends ExpressionContext {
		public TerminalNode PayableKeyword() { return getToken(SolidityParser.PayableKeyword, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public PayableExpressionContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class NewExpressionContext extends ExpressionContext {
		public TypeNameContext typeName() {
			return getRuleContext(TypeNameContext.class,0);
		}
		public NewExpressionContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class IndexAccessContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public IndexAccessContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class BitNotOperationContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public BitNotOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class BitOrOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public BitOrOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class NotOperationContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public NotOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class AndOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public AndOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class ModOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public ModOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class OrOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public OrOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class SuffixOperationContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public SuffixOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class MemberAccessContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public MemberAccessContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class ValueExpressionContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public NameValueListContext nameValueList() {
			return getRuleContext(NameValueListContext.class,0);
		}
		public ValueExpressionContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class ParenExpressionContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ParenExpressionContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class BitXorOperationContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public BitXorOperationContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class FunctionCallWithOptionsContext extends ExpressionContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public FunctionCallArgumentsContext functionCallArguments() {
			return getRuleContext(FunctionCallArgumentsContext.class,0);
		}
		public FunctionCallOptionsContext functionCallOptions() {
			return getRuleContext(FunctionCallOptionsContext.class,0);
		}
		public FunctionCallWithOptionsContext(ExpressionContext ctx) { copyFrom(ctx); }
	}
	@SuppressWarnings("CheckReturnValue")
	public static class EqualityComparisonContext extends ExpressionContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public EqualityComparisonContext(ExpressionContext ctx) { copyFrom(ctx); }
	}

	public final ExpressionContext expression() throws RecognitionException {
		return expression(0);
	}

	private ExpressionContext expression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		ExpressionContext _localctx = new ExpressionContext(_ctx, _parentState);
		ExpressionContext _prevctx = _localctx;
		int _startState = 128;
		enterRecursionRule(_localctx, 128, RULE_expression, _p);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(795);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,84,_ctx) ) {
			case 1:
				{
				_localctx = new NewExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;

				setState(768);
				match(T__61);
				setState(769);
				typeName(0);
				}
				break;
			case 2:
				{
				_localctx = new PayableExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(770);
				match(PayableKeyword);
				setState(771);
				match(T__22);
				setState(772);
				expression(0);
				setState(773);
				match(T__23);
				}
				break;
			case 3:
				{
				_localctx = new TypeConversionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(775);
				elementaryTypeName();
				setState(776);
				match(T__22);
				setState(777);
				expression(0);
				setState(778);
				match(T__23);
				}
				break;
			case 4:
				{
				_localctx = new ParenExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(780);
				match(T__22);
				setState(781);
				expression(0);
				setState(782);
				match(T__23);
				}
				break;
			case 5:
				{
				_localctx = new PrefixOperationContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(784);
				_la = _input.LA(1);
				if ( !(_la==T__59 || _la==T__60) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(785);
				expression(19);
				}
				break;
			case 6:
				{
				_localctx = new UnaryPrefixOperationContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(786);
				_la = _input.LA(1);
				if ( !(_la==T__63 || _la==T__64) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(787);
				expression(18);
				}
				break;
			case 7:
				{
				_localctx = new KeywordPrefixOperationContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(788);
				_la = _input.LA(1);
				if ( !(_la==T__65 || _la==T__66) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(789);
				expression(17);
				}
				break;
			case 8:
				{
				_localctx = new NotOperationContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(790);
				match(T__67);
				setState(791);
				expression(16);
				}
				break;
			case 9:
				{
				_localctx = new BitNotOperationContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(792);
				match(T__4);
				setState(793);
				expression(15);
				}
				break;
			case 10:
				{
				_localctx = new PrimaryContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(794);
				primaryExpression();
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(875);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,90,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					setState(873);
					_errHandler.sync(this);
					switch ( getInterpreter().adaptivePredict(_input,89,_ctx) ) {
					case 1:
						{
						_localctx = new ModOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(797);
						if (!(precpred(_ctx, 14))) throw new FailedPredicateException(this, "precpred(_ctx, 14)");
						setState(798);
						match(T__68);
						setState(799);
						expression(15);
						}
						break;
					case 2:
						{
						_localctx = new MulOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(800);
						if (!(precpred(_ctx, 13))) throw new FailedPredicateException(this, "precpred(_ctx, 13)");
						setState(801);
						_la = _input.LA(1);
						if ( !(((((_la - 13)) & ~0x3f) == 0 && ((1L << (_la - 13)) & 432345564227567617L) != 0)) ) {
						_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(802);
						expression(14);
						}
						break;
					case 3:
						{
						_localctx = new AddOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(803);
						if (!(precpred(_ctx, 12))) throw new FailedPredicateException(this, "precpred(_ctx, 12)");
						setState(804);
						_la = _input.LA(1);
						if ( !(_la==T__63 || _la==T__64) ) {
						_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(805);
						expression(13);
						}
						break;
					case 4:
						{
						_localctx = new ShiftOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(806);
						if (!(precpred(_ctx, 11))) throw new FailedPredicateException(this, "precpred(_ctx, 11)");
						setState(807);
						_la = _input.LA(1);
						if ( !(_la==T__71 || _la==T__72) ) {
						_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(808);
						expression(12);
						}
						break;
					case 5:
						{
						_localctx = new BitAndOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(809);
						if (!(precpred(_ctx, 10))) throw new FailedPredicateException(this, "precpred(_ctx, 10)");
						setState(810);
						match(T__73);
						setState(811);
						expression(11);
						}
						break;
					case 6:
						{
						_localctx = new BitXorOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(812);
						if (!(precpred(_ctx, 9))) throw new FailedPredicateException(this, "precpred(_ctx, 9)");
						setState(813);
						match(T__3);
						setState(814);
						expression(10);
						}
						break;
					case 7:
						{
						_localctx = new BitOrOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(815);
						if (!(precpred(_ctx, 8))) throw new FailedPredicateException(this, "precpred(_ctx, 8)");
						setState(816);
						match(T__74);
						setState(817);
						expression(9);
						}
						break;
					case 8:
						{
						_localctx = new OrderComparisonContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(818);
						if (!(precpred(_ctx, 7))) throw new FailedPredicateException(this, "precpred(_ctx, 7)");
						setState(819);
						_la = _input.LA(1);
						if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & 960L) != 0)) ) {
						_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(820);
						expression(8);
						}
						break;
					case 9:
						{
						_localctx = new EqualityComparisonContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(821);
						if (!(precpred(_ctx, 6))) throw new FailedPredicateException(this, "precpred(_ctx, 6)");
						setState(822);
						_la = _input.LA(1);
						if ( !(_la==T__75 || _la==T__76) ) {
						_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(823);
						expression(7);
						}
						break;
					case 10:
						{
						_localctx = new AndOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(824);
						if (!(precpred(_ctx, 5))) throw new FailedPredicateException(this, "precpred(_ctx, 5)");
						setState(825);
						match(T__77);
						setState(826);
						expression(6);
						}
						break;
					case 11:
						{
						_localctx = new OrOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(827);
						if (!(precpred(_ctx, 4))) throw new FailedPredicateException(this, "precpred(_ctx, 4)");
						setState(828);
						match(T__2);
						setState(829);
						expression(5);
						}
						break;
					case 12:
						{
						_localctx = new ConditionalContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(830);
						if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
						setState(831);
						match(T__78);
						setState(832);
						expression(0);
						setState(833);
						match(T__62);
						setState(834);
						expression(4);
						}
						break;
					case 13:
						{
						_localctx = new AssignmentContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(836);
						if (!(precpred(_ctx, 2))) throw new FailedPredicateException(this, "precpred(_ctx, 2)");
						setState(837);
						_la = _input.LA(1);
						if ( !(_la==T__9 || ((((_la - 80)) & ~0x3f) == 0 && ((1L << (_la - 80)) & 1023L) != 0)) ) {
						_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(838);
						expression(3);
						}
						break;
					case 14:
						{
						_localctx = new SuffixOperationContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(839);
						if (!(precpred(_ctx, 29))) throw new FailedPredicateException(this, "precpred(_ctx, 29)");
						setState(840);
						_la = _input.LA(1);
						if ( !(_la==T__59 || _la==T__60) ) {
						_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						}
						break;
					case 15:
						{
						_localctx = new IndexAccessContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(841);
						if (!(precpred(_ctx, 27))) throw new FailedPredicateException(this, "precpred(_ctx, 27)");
						setState(842);
						match(T__33);
						setState(844);
						_errHandler.sync(this);
						_la = _input.LA(1);
						if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
							{
							setState(843);
							expression(0);
							}
						}

						setState(846);
						match(T__34);
						}
						break;
					case 16:
						{
						_localctx = new IndexRangeAccessContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(847);
						if (!(precpred(_ctx, 26))) throw new FailedPredicateException(this, "precpred(_ctx, 26)");
						setState(848);
						match(T__33);
						setState(850);
						_errHandler.sync(this);
						_la = _input.LA(1);
						if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
							{
							setState(849);
							expression(0);
							}
						}

						setState(852);
						match(T__62);
						setState(854);
						_errHandler.sync(this);
						_la = _input.LA(1);
						if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
							{
							setState(853);
							expression(0);
							}
						}

						setState(856);
						match(T__34);
						}
						break;
					case 17:
						{
						_localctx = new MemberAccessContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(857);
						if (!(precpred(_ctx, 25))) throw new FailedPredicateException(this, "precpred(_ctx, 25)");
						setState(858);
						match(T__36);
						setState(859);
						identifier();
						}
						break;
					case 18:
						{
						_localctx = new ValueExpressionContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(860);
						if (!(precpred(_ctx, 22))) throw new FailedPredicateException(this, "precpred(_ctx, 22)");
						setState(861);
						match(T__14);
						setState(862);
						nameValueList();
						setState(863);
						match(T__16);
						}
						break;
					case 19:
						{
						_localctx = new FunctionCallWithOptionsContext(new ExpressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(865);
						if (!(precpred(_ctx, 21))) throw new FailedPredicateException(this, "precpred(_ctx, 21)");
						setState(867);
						_errHandler.sync(this);
						_la = _input.LA(1);
						if (_la==T__14) {
							{
							setState(866);
							functionCallOptions();
							}
						}

						setState(869);
						match(T__22);
						setState(870);
						functionCallArguments();
						setState(871);
						match(T__23);
						}
						break;
					}
					} 
				}
				setState(877);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,90,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class PrimaryExpressionContext extends ParserRuleContext {
		public TerminalNode TypeKeyword() { return getToken(SolidityParser.TypeKeyword, 0); }
		public TerminalNode PayableKeyword() { return getToken(SolidityParser.PayableKeyword, 0); }
		public TerminalNode BooleanLiteral() { return getToken(SolidityParser.BooleanLiteral, 0); }
		public NumberLiteralContext numberLiteral() {
			return getRuleContext(NumberLiteralContext.class,0);
		}
		public HexLiteralContext hexLiteral() {
			return getRuleContext(HexLiteralContext.class,0);
		}
		public TupleExpressionContext tupleExpression() {
			return getRuleContext(TupleExpressionContext.class,0);
		}
		public TypeNameExpressionContext typeNameExpression() {
			return getRuleContext(TypeNameExpressionContext.class,0);
		}
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public StringLiteralContext stringLiteral() {
			return getRuleContext(StringLiteralContext.class,0);
		}
		public PrimaryExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_primaryExpression; }
	}

	public final PrimaryExpressionContext primaryExpression() throws RecognitionException {
		PrimaryExpressionContext _localctx = new PrimaryExpressionContext(_ctx, getState());
		enterRule(_localctx, 130, RULE_primaryExpression);
		try {
			setState(895);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,93,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(878);
				match(TypeKeyword);
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(879);
				match(PayableKeyword);
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(880);
				match(BooleanLiteral);
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(881);
				numberLiteral();
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(882);
				hexLiteral();
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(883);
				tupleExpression();
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(884);
				typeNameExpression();
				setState(887);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,91,_ctx) ) {
				case 1:
					{
					setState(885);
					match(T__33);
					setState(886);
					match(T__34);
					}
					break;
				}
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(889);
				identifier();
				setState(892);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,92,_ctx) ) {
				case 1:
					{
					setState(890);
					match(T__33);
					setState(891);
					match(T__34);
					}
					break;
				}
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(894);
				stringLiteral();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ExpressionListContext extends ParserRuleContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public ExpressionListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expressionList; }
	}

	public final ExpressionListContext expressionList() throws RecognitionException {
		ExpressionListContext _localctx = new ExpressionListContext(_ctx, getState());
		enterRule(_localctx, 132, RULE_expressionList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(897);
			expression(0);
			setState(902);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__15) {
				{
				{
				setState(898);
				match(T__15);
				setState(899);
				expression(0);
				}
				}
				setState(904);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class NameValueListContext extends ParserRuleContext {
		public List<NameValueContext> nameValue() {
			return getRuleContexts(NameValueContext.class);
		}
		public NameValueContext nameValue(int i) {
			return getRuleContext(NameValueContext.class,i);
		}
		public NameValueListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_nameValueList; }
	}

	public final NameValueListContext nameValueList() throws RecognitionException {
		NameValueListContext _localctx = new NameValueListContext(_ctx, getState());
		enterRule(_localctx, 134, RULE_nameValueList);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(905);
			nameValue();
			setState(910);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,95,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(906);
					match(T__15);
					setState(907);
					nameValue();
					}
					} 
				}
				setState(912);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,95,_ctx);
			}
			setState(914);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__15) {
				{
				setState(913);
				match(T__15);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class NameValueContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public NameValueContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_nameValue; }
	}

	public final NameValueContext nameValue() throws RecognitionException {
		NameValueContext _localctx = new NameValueContext(_ctx, getState());
		enterRule(_localctx, 136, RULE_nameValue);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(916);
			identifier();
			setState(917);
			match(T__62);
			setState(918);
			expression(0);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionCallOptionsContext extends ParserRuleContext {
		public NameValueListContext nameValueList() {
			return getRuleContext(NameValueListContext.class,0);
		}
		public FunctionCallOptionsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionCallOptions; }
	}

	public final FunctionCallOptionsContext functionCallOptions() throws RecognitionException {
		FunctionCallOptionsContext _localctx = new FunctionCallOptionsContext(_ctx, getState());
		enterRule(_localctx, 138, RULE_functionCallOptions);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(920);
			match(T__14);
			setState(922);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
				{
				setState(921);
				nameValueList();
				}
			}

			setState(924);
			match(T__16);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionCallArgumentsContext extends ParserRuleContext {
		public NameValueListContext nameValueList() {
			return getRuleContext(NameValueListContext.class,0);
		}
		public ExpressionListContext expressionList() {
			return getRuleContext(ExpressionListContext.class,0);
		}
		public FunctionCallArgumentsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionCallArguments; }
	}

	public final FunctionCallArgumentsContext functionCallArguments() throws RecognitionException {
		FunctionCallArgumentsContext _localctx = new FunctionCallArgumentsContext(_ctx, getState());
		enterRule(_localctx, 140, RULE_functionCallArguments);
		int _la;
		try {
			setState(934);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__14:
				enterOuterAlt(_localctx, 1);
				{
				setState(926);
				match(T__14);
				setState(928);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
					{
					setState(927);
					nameValueList();
					}
				}

				setState(930);
				match(T__16);
				}
				break;
			case T__4:
			case T__13:
			case T__22:
			case T__23:
			case T__24:
			case T__33:
			case T__35:
			case T__41:
			case T__54:
			case T__55:
			case T__56:
			case T__57:
			case T__58:
			case T__59:
			case T__60:
			case T__61:
			case T__63:
			case T__64:
			case T__65:
			case T__66:
			case T__67:
			case T__96:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
			case BooleanLiteral:
			case DecimalNumber:
			case HexNumber:
			case HexLiteralFragment:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
			case StringLiteralFragment:
				enterOuterAlt(_localctx, 2);
				{
				setState(932);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
					{
					setState(931);
					expressionList();
					}
				}

				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FunctionCallContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public FunctionCallArgumentsContext functionCallArguments() {
			return getRuleContext(FunctionCallArgumentsContext.class,0);
		}
		public FunctionCallContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionCall; }
	}

	public final FunctionCallContext functionCall() throws RecognitionException {
		FunctionCallContext _localctx = new FunctionCallContext(_ctx, getState());
		enterRule(_localctx, 142, RULE_functionCall);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(936);
			expression(0);
			setState(937);
			match(T__22);
			setState(938);
			functionCallArguments();
			setState(939);
			match(T__23);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyBlockContext extends ParserRuleContext {
		public List<AssemblyItemContext> assemblyItem() {
			return getRuleContexts(AssemblyItemContext.class);
		}
		public AssemblyItemContext assemblyItem(int i) {
			return getRuleContext(AssemblyItemContext.class,i);
		}
		public AssemblyBlockContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyBlock; }
	}

	public final AssemblyBlockContext assemblyBlock() throws RecognitionException {
		AssemblyBlockContext _localctx = new AssemblyBlockContext(_ctx, getState());
		enterRule(_localctx, 144, RULE_assemblyBlock);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(941);
			match(T__14);
			setState(945);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & 618132312965562368L) != 0) || ((((_la - 90)) & ~0x3f) == 0 && ((1L << (_la - 90)) & 2199022567565L) != 0)) {
				{
				{
				setState(942);
				assemblyItem();
				}
				}
				setState(947);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(948);
			match(T__16);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyItemContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public AssemblyLocalDefinitionContext assemblyLocalDefinition() {
			return getRuleContext(AssemblyLocalDefinitionContext.class,0);
		}
		public AssemblyAssignmentContext assemblyAssignment() {
			return getRuleContext(AssemblyAssignmentContext.class,0);
		}
		public AssemblyStackAssignmentContext assemblyStackAssignment() {
			return getRuleContext(AssemblyStackAssignmentContext.class,0);
		}
		public LabelDefinitionContext labelDefinition() {
			return getRuleContext(LabelDefinitionContext.class,0);
		}
		public AssemblySwitchContext assemblySwitch() {
			return getRuleContext(AssemblySwitchContext.class,0);
		}
		public AssemblyFunctionDefinitionContext assemblyFunctionDefinition() {
			return getRuleContext(AssemblyFunctionDefinitionContext.class,0);
		}
		public AssemblyForContext assemblyFor() {
			return getRuleContext(AssemblyForContext.class,0);
		}
		public AssemblyIfContext assemblyIf() {
			return getRuleContext(AssemblyIfContext.class,0);
		}
		public TerminalNode BreakKeyword() { return getToken(SolidityParser.BreakKeyword, 0); }
		public TerminalNode ContinueKeyword() { return getToken(SolidityParser.ContinueKeyword, 0); }
		public TerminalNode LeaveKeyword() { return getToken(SolidityParser.LeaveKeyword, 0); }
		public SubAssemblyContext subAssembly() {
			return getRuleContext(SubAssemblyContext.class,0);
		}
		public NumberLiteralContext numberLiteral() {
			return getRuleContext(NumberLiteralContext.class,0);
		}
		public StringLiteralContext stringLiteral() {
			return getRuleContext(StringLiteralContext.class,0);
		}
		public HexLiteralContext hexLiteral() {
			return getRuleContext(HexLiteralContext.class,0);
		}
		public AssemblyItemContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyItem; }
	}

	public final AssemblyItemContext assemblyItem() throws RecognitionException {
		AssemblyItemContext _localctx = new AssemblyItemContext(_ctx, getState());
		enterRule(_localctx, 146, RULE_assemblyItem);
		try {
			setState(968);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,102,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(950);
				identifier();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(951);
				assemblyBlock();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(952);
				assemblyExpression();
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(953);
				assemblyLocalDefinition();
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(954);
				assemblyAssignment();
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(955);
				assemblyStackAssignment();
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(956);
				labelDefinition();
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(957);
				assemblySwitch();
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(958);
				assemblyFunctionDefinition();
				}
				break;
			case 10:
				enterOuterAlt(_localctx, 10);
				{
				setState(959);
				assemblyFor();
				}
				break;
			case 11:
				enterOuterAlt(_localctx, 11);
				{
				setState(960);
				assemblyIf();
				}
				break;
			case 12:
				enterOuterAlt(_localctx, 12);
				{
				setState(961);
				match(BreakKeyword);
				}
				break;
			case 13:
				enterOuterAlt(_localctx, 13);
				{
				setState(962);
				match(ContinueKeyword);
				}
				break;
			case 14:
				enterOuterAlt(_localctx, 14);
				{
				setState(963);
				match(LeaveKeyword);
				}
				break;
			case 15:
				enterOuterAlt(_localctx, 15);
				{
				setState(964);
				subAssembly();
				}
				break;
			case 16:
				enterOuterAlt(_localctx, 16);
				{
				setState(965);
				numberLiteral();
				}
				break;
			case 17:
				enterOuterAlt(_localctx, 17);
				{
				setState(966);
				stringLiteral();
				}
				break;
			case 18:
				enterOuterAlt(_localctx, 18);
				{
				setState(967);
				hexLiteral();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyExpressionContext extends ParserRuleContext {
		public AssemblyCallContext assemblyCall() {
			return getRuleContext(AssemblyCallContext.class,0);
		}
		public AssemblyLiteralContext assemblyLiteral() {
			return getRuleContext(AssemblyLiteralContext.class,0);
		}
		public AssemblyMemberContext assemblyMember() {
			return getRuleContext(AssemblyMemberContext.class,0);
		}
		public AssemblyExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyExpression; }
	}

	public final AssemblyExpressionContext assemblyExpression() throws RecognitionException {
		AssemblyExpressionContext _localctx = new AssemblyExpressionContext(_ctx, getState());
		enterRule(_localctx, 148, RULE_assemblyExpression);
		try {
			setState(973);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,103,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(970);
				assemblyCall();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(971);
				assemblyLiteral();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(972);
				assemblyMember();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyMemberContext extends ParserRuleContext {
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public AssemblyMemberContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyMember; }
	}

	public final AssemblyMemberContext assemblyMember() throws RecognitionException {
		AssemblyMemberContext _localctx = new AssemblyMemberContext(_ctx, getState());
		enterRule(_localctx, 150, RULE_assemblyMember);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(975);
			identifier();
			setState(976);
			match(T__36);
			setState(977);
			identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyCallContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public List<AssemblyExpressionContext> assemblyExpression() {
			return getRuleContexts(AssemblyExpressionContext.class);
		}
		public AssemblyExpressionContext assemblyExpression(int i) {
			return getRuleContext(AssemblyExpressionContext.class,i);
		}
		public AssemblyCallContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyCall; }
	}

	public final AssemblyCallContext assemblyCall() throws RecognitionException {
		AssemblyCallContext _localctx = new AssemblyCallContext(_ctx, getState());
		enterRule(_localctx, 152, RULE_assemblyCall);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(983);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__51:
				{
				setState(979);
				match(T__51);
				}
				break;
			case T__35:
				{
				setState(980);
				match(T__35);
				}
				break;
			case T__58:
				{
				setState(981);
				match(T__58);
				}
				break;
			case T__13:
			case T__24:
			case T__41:
			case T__54:
			case T__96:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
				{
				setState(982);
				identifier();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(997);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,107,_ctx) ) {
			case 1:
				{
				setState(985);
				match(T__22);
				setState(987);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 616997615749316608L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179863809L) != 0)) {
					{
					setState(986);
					assemblyExpression();
					}
				}

				setState(993);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==T__15) {
					{
					{
					setState(989);
					match(T__15);
					setState(990);
					assemblyExpression();
					}
					}
					setState(995);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				setState(996);
				match(T__23);
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyLocalDefinitionContext extends ParserRuleContext {
		public AssemblyIdentifierOrListContext assemblyIdentifierOrList() {
			return getRuleContext(AssemblyIdentifierOrListContext.class,0);
		}
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public AssemblyLocalDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyLocalDefinition; }
	}

	public final AssemblyLocalDefinitionContext assemblyLocalDefinition() throws RecognitionException {
		AssemblyLocalDefinitionContext _localctx = new AssemblyLocalDefinitionContext(_ctx, getState());
		enterRule(_localctx, 154, RULE_assemblyLocalDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(999);
			match(T__89);
			setState(1000);
			assemblyIdentifierOrList();
			setState(1003);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__90) {
				{
				setState(1001);
				match(T__90);
				setState(1002);
				assemblyExpression();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyAssignmentContext extends ParserRuleContext {
		public AssemblyIdentifierOrListContext assemblyIdentifierOrList() {
			return getRuleContext(AssemblyIdentifierOrListContext.class,0);
		}
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public AssemblyAssignmentContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyAssignment; }
	}

	public final AssemblyAssignmentContext assemblyAssignment() throws RecognitionException {
		AssemblyAssignmentContext _localctx = new AssemblyAssignmentContext(_ctx, getState());
		enterRule(_localctx, 156, RULE_assemblyAssignment);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1005);
			assemblyIdentifierOrList();
			setState(1006);
			match(T__90);
			setState(1007);
			assemblyExpression();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyIdentifierOrListContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyMemberContext assemblyMember() {
			return getRuleContext(AssemblyMemberContext.class,0);
		}
		public AssemblyIdentifierListContext assemblyIdentifierList() {
			return getRuleContext(AssemblyIdentifierListContext.class,0);
		}
		public AssemblyIdentifierOrListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyIdentifierOrList; }
	}

	public final AssemblyIdentifierOrListContext assemblyIdentifierOrList() throws RecognitionException {
		AssemblyIdentifierOrListContext _localctx = new AssemblyIdentifierOrListContext(_ctx, getState());
		enterRule(_localctx, 158, RULE_assemblyIdentifierOrList);
		try {
			setState(1015);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,109,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(1009);
				identifier();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(1010);
				assemblyMember();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(1011);
				match(T__22);
				setState(1012);
				assemblyIdentifierList();
				setState(1013);
				match(T__23);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyIdentifierListContext extends ParserRuleContext {
		public List<IdentifierContext> identifier() {
			return getRuleContexts(IdentifierContext.class);
		}
		public IdentifierContext identifier(int i) {
			return getRuleContext(IdentifierContext.class,i);
		}
		public AssemblyIdentifierListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyIdentifierList; }
	}

	public final AssemblyIdentifierListContext assemblyIdentifierList() throws RecognitionException {
		AssemblyIdentifierListContext _localctx = new AssemblyIdentifierListContext(_ctx, getState());
		enterRule(_localctx, 160, RULE_assemblyIdentifierList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1017);
			identifier();
			setState(1022);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__15) {
				{
				{
				setState(1018);
				match(T__15);
				setState(1019);
				identifier();
				}
				}
				setState(1024);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyStackAssignmentContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyStackAssignmentContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyStackAssignment; }
	}

	public final AssemblyStackAssignmentContext assemblyStackAssignment() throws RecognitionException {
		AssemblyStackAssignmentContext _localctx = new AssemblyStackAssignmentContext(_ctx, getState());
		enterRule(_localctx, 162, RULE_assemblyStackAssignment);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1025);
			match(T__91);
			setState(1026);
			identifier();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class LabelDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public LabelDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_labelDefinition; }
	}

	public final LabelDefinitionContext labelDefinition() throws RecognitionException {
		LabelDefinitionContext _localctx = new LabelDefinitionContext(_ctx, getState());
		enterRule(_localctx, 164, RULE_labelDefinition);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1028);
			identifier();
			setState(1029);
			match(T__62);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblySwitchContext extends ParserRuleContext {
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public List<AssemblyCaseContext> assemblyCase() {
			return getRuleContexts(AssemblyCaseContext.class);
		}
		public AssemblyCaseContext assemblyCase(int i) {
			return getRuleContext(AssemblyCaseContext.class,i);
		}
		public AssemblySwitchContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblySwitch; }
	}

	public final AssemblySwitchContext assemblySwitch() throws RecognitionException {
		AssemblySwitchContext _localctx = new AssemblySwitchContext(_ctx, getState());
		enterRule(_localctx, 166, RULE_assemblySwitch);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1031);
			match(T__92);
			setState(1032);
			assemblyExpression();
			setState(1036);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__93 || _la==T__94) {
				{
				{
				setState(1033);
				assemblyCase();
				}
				}
				setState(1038);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyCaseContext extends ParserRuleContext {
		public AssemblyLiteralContext assemblyLiteral() {
			return getRuleContext(AssemblyLiteralContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyCaseContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyCase; }
	}

	public final AssemblyCaseContext assemblyCase() throws RecognitionException {
		AssemblyCaseContext _localctx = new AssemblyCaseContext(_ctx, getState());
		enterRule(_localctx, 168, RULE_assemblyCase);
		try {
			setState(1045);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__93:
				enterOuterAlt(_localctx, 1);
				{
				setState(1039);
				match(T__93);
				setState(1040);
				assemblyLiteral();
				setState(1041);
				assemblyBlock();
				}
				break;
			case T__94:
				enterOuterAlt(_localctx, 2);
				{
				setState(1043);
				match(T__94);
				setState(1044);
				assemblyBlock();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyFunctionDefinitionContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyIdentifierListContext assemblyIdentifierList() {
			return getRuleContext(AssemblyIdentifierListContext.class,0);
		}
		public AssemblyFunctionReturnsContext assemblyFunctionReturns() {
			return getRuleContext(AssemblyFunctionReturnsContext.class,0);
		}
		public AssemblyFunctionDefinitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyFunctionDefinition; }
	}

	public final AssemblyFunctionDefinitionContext assemblyFunctionDefinition() throws RecognitionException {
		AssemblyFunctionDefinitionContext _localctx = new AssemblyFunctionDefinitionContext(_ctx, getState());
		enterRule(_localctx, 170, RULE_assemblyFunctionDefinition);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1047);
			match(T__29);
			setState(1048);
			identifier();
			setState(1049);
			match(T__22);
			setState(1051);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & 36033195099045888L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 8589926401L) != 0)) {
				{
				setState(1050);
				assemblyIdentifierList();
				}
			}

			setState(1053);
			match(T__23);
			setState(1055);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__95) {
				{
				setState(1054);
				assemblyFunctionReturns();
				}
			}

			setState(1057);
			assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyFunctionReturnsContext extends ParserRuleContext {
		public AssemblyIdentifierListContext assemblyIdentifierList() {
			return getRuleContext(AssemblyIdentifierListContext.class,0);
		}
		public AssemblyFunctionReturnsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyFunctionReturns; }
	}

	public final AssemblyFunctionReturnsContext assemblyFunctionReturns() throws RecognitionException {
		AssemblyFunctionReturnsContext _localctx = new AssemblyFunctionReturnsContext(_ctx, getState());
		enterRule(_localctx, 172, RULE_assemblyFunctionReturns);
		try {
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(1059);
			match(T__95);
			setState(1060);
			assemblyIdentifierList();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyForContext extends ParserRuleContext {
		public List<AssemblyExpressionContext> assemblyExpression() {
			return getRuleContexts(AssemblyExpressionContext.class);
		}
		public AssemblyExpressionContext assemblyExpression(int i) {
			return getRuleContext(AssemblyExpressionContext.class,i);
		}
		public List<AssemblyBlockContext> assemblyBlock() {
			return getRuleContexts(AssemblyBlockContext.class);
		}
		public AssemblyBlockContext assemblyBlock(int i) {
			return getRuleContext(AssemblyBlockContext.class,i);
		}
		public AssemblyForContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyFor; }
	}

	public final AssemblyForContext assemblyFor() throws RecognitionException {
		AssemblyForContext _localctx = new AssemblyForContext(_ctx, getState());
		enterRule(_localctx, 174, RULE_assemblyFor);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1062);
			match(T__26);
			setState(1065);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__14:
				{
				setState(1063);
				assemblyBlock();
				}
				break;
			case T__13:
			case T__24:
			case T__35:
			case T__41:
			case T__51:
			case T__54:
			case T__58:
			case T__96:
			case DecimalNumber:
			case HexNumber:
			case HexLiteralFragment:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
			case StringLiteralFragment:
				{
				setState(1064);
				assemblyExpression();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(1067);
			assemblyExpression();
			setState(1070);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__14:
				{
				setState(1068);
				assemblyBlock();
				}
				break;
			case T__13:
			case T__24:
			case T__35:
			case T__41:
			case T__51:
			case T__54:
			case T__58:
			case T__96:
			case DecimalNumber:
			case HexNumber:
			case HexLiteralFragment:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
			case StringLiteralFragment:
				{
				setState(1069);
				assemblyExpression();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(1072);
			assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyIfContext extends ParserRuleContext {
		public AssemblyExpressionContext assemblyExpression() {
			return getRuleContext(AssemblyExpressionContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public AssemblyIfContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyIf; }
	}

	public final AssemblyIfContext assemblyIf() throws RecognitionException {
		AssemblyIfContext _localctx = new AssemblyIfContext(_ctx, getState());
		enterRule(_localctx, 176, RULE_assemblyIf);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1074);
			match(T__42);
			setState(1075);
			assemblyExpression();
			setState(1076);
			assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AssemblyLiteralContext extends ParserRuleContext {
		public StringLiteralContext stringLiteral() {
			return getRuleContext(StringLiteralContext.class,0);
		}
		public TerminalNode DecimalNumber() { return getToken(SolidityParser.DecimalNumber, 0); }
		public TerminalNode HexNumber() { return getToken(SolidityParser.HexNumber, 0); }
		public HexLiteralContext hexLiteral() {
			return getRuleContext(HexLiteralContext.class,0);
		}
		public AssemblyLiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assemblyLiteral; }
	}

	public final AssemblyLiteralContext assemblyLiteral() throws RecognitionException {
		AssemblyLiteralContext _localctx = new AssemblyLiteralContext(_ctx, getState());
		enterRule(_localctx, 178, RULE_assemblyLiteral);
		try {
			setState(1082);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case StringLiteralFragment:
				enterOuterAlt(_localctx, 1);
				{
				setState(1078);
				stringLiteral();
				}
				break;
			case DecimalNumber:
				enterOuterAlt(_localctx, 2);
				{
				setState(1079);
				match(DecimalNumber);
				}
				break;
			case HexNumber:
				enterOuterAlt(_localctx, 3);
				{
				setState(1080);
				match(HexNumber);
				}
				break;
			case HexLiteralFragment:
				enterOuterAlt(_localctx, 4);
				{
				setState(1081);
				hexLiteral();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class SubAssemblyContext extends ParserRuleContext {
		public IdentifierContext identifier() {
			return getRuleContext(IdentifierContext.class,0);
		}
		public AssemblyBlockContext assemblyBlock() {
			return getRuleContext(AssemblyBlockContext.class,0);
		}
		public SubAssemblyContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_subAssembly; }
	}

	public final SubAssemblyContext subAssembly() throws RecognitionException {
		SubAssemblyContext _localctx = new SubAssemblyContext(_ctx, getState());
		enterRule(_localctx, 180, RULE_subAssembly);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1084);
			match(T__49);
			setState(1085);
			identifier();
			setState(1086);
			assemblyBlock();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class TupleExpressionContext extends ParserRuleContext {
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public TupleExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_tupleExpression; }
	}

	public final TupleExpressionContext tupleExpression() throws RecognitionException {
		TupleExpressionContext _localctx = new TupleExpressionContext(_ctx, getState());
		enterRule(_localctx, 182, RULE_tupleExpression);
		int _la;
		try {
			setState(1116);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__22:
				enterOuterAlt(_localctx, 1);
				{
				setState(1088);
				match(T__22);
				setState(1101);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,121,_ctx) ) {
				case 1:
					{
					setState(1090);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
						{
						setState(1089);
						expression(0);
						}
					}

					setState(1098);
					_errHandler.sync(this);
					_la = _input.LA(1);
					while (_la==T__15) {
						{
						{
						setState(1092);
						match(T__15);
						setState(1094);
						_errHandler.sync(this);
						_la = _input.LA(1);
						if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
							{
							setState(1093);
							expression(0);
							}
						}

						}
						}
						setState(1100);
						_errHandler.sync(this);
						_la = _input.LA(1);
					}
					}
					break;
				}
				setState(1103);
				match(T__23);
				}
				break;
			case T__33:
				enterOuterAlt(_localctx, 2);
				{
				setState(1104);
				match(T__33);
				setState(1113);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (((((_la - 5)) & ~0x3f) == 0 && ((1L << (_la - 5)) & -289356135933935103L) != 0) || ((((_la - 97)) & ~0x3f) == 0 && ((1L << (_la - 97)) & 17179864061L) != 0)) {
					{
					setState(1105);
					expression(0);
					setState(1110);
					_errHandler.sync(this);
					_la = _input.LA(1);
					while (_la==T__15) {
						{
						{
						setState(1106);
						match(T__15);
						setState(1107);
						expression(0);
						}
						}
						setState(1112);
						_errHandler.sync(this);
						_la = _input.LA(1);
					}
					}
				}

				setState(1115);
				match(T__34);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class TypeNameExpressionContext extends ParserRuleContext {
		public ElementaryTypeNameContext elementaryTypeName() {
			return getRuleContext(ElementaryTypeNameContext.class,0);
		}
		public UserDefinedTypeNameContext userDefinedTypeName() {
			return getRuleContext(UserDefinedTypeNameContext.class,0);
		}
		public TypeNameExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_typeNameExpression; }
	}

	public final TypeNameExpressionContext typeNameExpression() throws RecognitionException {
		TypeNameExpressionContext _localctx = new TypeNameExpressionContext(_ctx, getState());
		enterRule(_localctx, 184, RULE_typeNameExpression);
		try {
			setState(1120);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__35:
			case T__55:
			case T__56:
			case T__57:
			case T__58:
			case Int:
			case Uint:
			case Byte:
			case Fixed:
			case Ufixed:
				enterOuterAlt(_localctx, 1);
				{
				setState(1118);
				elementaryTypeName();
				}
				break;
			case T__13:
			case T__24:
			case T__41:
			case T__54:
			case T__96:
			case AnonymousKeyword:
			case BreakKeyword:
			case ConstantKeyword:
			case ImmutableKeyword:
			case ContinueKeyword:
			case LeaveKeyword:
			case ExternalKeyword:
			case IndexedKeyword:
			case InternalKeyword:
			case PayableKeyword:
			case PrivateKeyword:
			case PublicKeyword:
			case VirtualKeyword:
			case PureKeyword:
			case TypeKeyword:
			case ViewKeyword:
			case ConstructorKeyword:
			case FallbackKeyword:
			case ReceiveKeyword:
			case Identifier:
				enterOuterAlt(_localctx, 2);
				{
				setState(1119);
				userDefinedTypeName();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class NumberLiteralContext extends ParserRuleContext {
		public TerminalNode DecimalNumber() { return getToken(SolidityParser.DecimalNumber, 0); }
		public TerminalNode HexNumber() { return getToken(SolidityParser.HexNumber, 0); }
		public TerminalNode NumberUnit() { return getToken(SolidityParser.NumberUnit, 0); }
		public NumberLiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_numberLiteral; }
	}

	public final NumberLiteralContext numberLiteral() throws RecognitionException {
		NumberLiteralContext _localctx = new NumberLiteralContext(_ctx, getState());
		enterRule(_localctx, 186, RULE_numberLiteral);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1122);
			_la = _input.LA(1);
			if ( !(_la==DecimalNumber || _la==HexNumber) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			setState(1124);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,126,_ctx) ) {
			case 1:
				{
				setState(1123);
				match(NumberUnit);
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class IdentifierContext extends ParserRuleContext {
		public AllKeywordsContext allKeywords() {
			return getRuleContext(AllKeywordsContext.class,0);
		}
		public TerminalNode ReceiveKeyword() { return getToken(SolidityParser.ReceiveKeyword, 0); }
		public TerminalNode Identifier() { return getToken(SolidityParser.Identifier, 0); }
		public IdentifierContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_identifier; }
	}

	public final IdentifierContext identifier() throws RecognitionException {
		IdentifierContext _localctx = new IdentifierContext(_ctx, getState());
		enterRule(_localctx, 188, RULE_identifier);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1134);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,127,_ctx) ) {
			case 1:
				{
				setState(1126);
				allKeywords();
				}
				break;
			case 2:
				{
				setState(1127);
				match(T__13);
				}
				break;
			case 3:
				{
				setState(1128);
				match(T__41);
				}
				break;
			case 4:
				{
				setState(1129);
				match(ReceiveKeyword);
				}
				break;
			case 5:
				{
				setState(1130);
				match(T__96);
				}
				break;
			case 6:
				{
				setState(1131);
				match(T__54);
				}
				break;
			case 7:
				{
				setState(1132);
				match(T__24);
				}
				break;
			case 8:
				{
				setState(1133);
				match(Identifier);
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class HexLiteralContext extends ParserRuleContext {
		public List<TerminalNode> HexLiteralFragment() { return getTokens(SolidityParser.HexLiteralFragment); }
		public TerminalNode HexLiteralFragment(int i) {
			return getToken(SolidityParser.HexLiteralFragment, i);
		}
		public HexLiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_hexLiteral; }
	}

	public final HexLiteralContext hexLiteral() throws RecognitionException {
		HexLiteralContext _localctx = new HexLiteralContext(_ctx, getState());
		enterRule(_localctx, 190, RULE_hexLiteral);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(1137); 
			_errHandler.sync(this);
			_alt = 1;
			do {
				switch (_alt) {
				case 1:
					{
					{
					setState(1136);
					match(HexLiteralFragment);
					}
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				setState(1139); 
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,128,_ctx);
			} while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER );
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VisibilityKeywordContext extends ParserRuleContext {
		public TerminalNode PublicKeyword() { return getToken(SolidityParser.PublicKeyword, 0); }
		public TerminalNode PrivateKeyword() { return getToken(SolidityParser.PrivateKeyword, 0); }
		public TerminalNode ExternalKeyword() { return getToken(SolidityParser.ExternalKeyword, 0); }
		public TerminalNode InternalKeyword() { return getToken(SolidityParser.InternalKeyword, 0); }
		public VisibilityKeywordContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_visibilityKeyword; }
	}

	public final VisibilityKeywordContext visibilityKeyword() throws RecognitionException {
		VisibilityKeywordContext _localctx = new VisibilityKeywordContext(_ctx, getState());
		enterRule(_localctx, 192, RULE_visibilityKeyword);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1141);
			_la = _input.LA(1);
			if ( !(((((_la - 116)) & ~0x3f) == 0 && ((1L << (_la - 116)) & 53L) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AllKeywordsContext extends ParserRuleContext {
		public TerminalNode AnonymousKeyword() { return getToken(SolidityParser.AnonymousKeyword, 0); }
		public TerminalNode BreakKeyword() { return getToken(SolidityParser.BreakKeyword, 0); }
		public TerminalNode ConstantKeyword() { return getToken(SolidityParser.ConstantKeyword, 0); }
		public TerminalNode ImmutableKeyword() { return getToken(SolidityParser.ImmutableKeyword, 0); }
		public TerminalNode ContinueKeyword() { return getToken(SolidityParser.ContinueKeyword, 0); }
		public TerminalNode LeaveKeyword() { return getToken(SolidityParser.LeaveKeyword, 0); }
		public TerminalNode IndexedKeyword() { return getToken(SolidityParser.IndexedKeyword, 0); }
		public VisibilityKeywordContext visibilityKeyword() {
			return getRuleContext(VisibilityKeywordContext.class,0);
		}
		public TerminalNode PayableKeyword() { return getToken(SolidityParser.PayableKeyword, 0); }
		public TerminalNode VirtualKeyword() { return getToken(SolidityParser.VirtualKeyword, 0); }
		public TerminalNode PureKeyword() { return getToken(SolidityParser.PureKeyword, 0); }
		public TerminalNode TypeKeyword() { return getToken(SolidityParser.TypeKeyword, 0); }
		public TerminalNode ViewKeyword() { return getToken(SolidityParser.ViewKeyword, 0); }
		public TerminalNode ConstructorKeyword() { return getToken(SolidityParser.ConstructorKeyword, 0); }
		public TerminalNode FallbackKeyword() { return getToken(SolidityParser.FallbackKeyword, 0); }
		public TerminalNode ReceiveKeyword() { return getToken(SolidityParser.ReceiveKeyword, 0); }
		public AllKeywordsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_allKeywords; }
	}

	public final AllKeywordsContext allKeywords() throws RecognitionException {
		AllKeywordsContext _localctx = new AllKeywordsContext(_ctx, getState());
		enterRule(_localctx, 194, RULE_allKeywords);
		try {
			setState(1159);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case AnonymousKeyword:
				enterOuterAlt(_localctx, 1);
				{
				setState(1143);
				match(AnonymousKeyword);
				}
				break;
			case BreakKeyword:
				enterOuterAlt(_localctx, 2);
				{
				setState(1144);
				match(BreakKeyword);
				}
				break;
			case ConstantKeyword:
				enterOuterAlt(_localctx, 3);
				{
				setState(1145);
				match(ConstantKeyword);
				}
				break;
			case ImmutableKeyword:
				enterOuterAlt(_localctx, 4);
				{
				setState(1146);
				match(ImmutableKeyword);
				}
				break;
			case ContinueKeyword:
				enterOuterAlt(_localctx, 5);
				{
				setState(1147);
				match(ContinueKeyword);
				}
				break;
			case LeaveKeyword:
				enterOuterAlt(_localctx, 6);
				{
				setState(1148);
				match(LeaveKeyword);
				}
				break;
			case IndexedKeyword:
				enterOuterAlt(_localctx, 7);
				{
				setState(1149);
				match(IndexedKeyword);
				}
				break;
			case ExternalKeyword:
			case InternalKeyword:
			case PrivateKeyword:
			case PublicKeyword:
				enterOuterAlt(_localctx, 8);
				{
				setState(1150);
				visibilityKeyword();
				}
				break;
			case PayableKeyword:
				enterOuterAlt(_localctx, 9);
				{
				setState(1151);
				match(PayableKeyword);
				}
				break;
			case VirtualKeyword:
				enterOuterAlt(_localctx, 10);
				{
				setState(1152);
				match(VirtualKeyword);
				}
				break;
			case PureKeyword:
				enterOuterAlt(_localctx, 11);
				{
				setState(1153);
				match(PureKeyword);
				}
				break;
			case TypeKeyword:
				enterOuterAlt(_localctx, 12);
				{
				setState(1154);
				match(TypeKeyword);
				}
				break;
			case ViewKeyword:
				enterOuterAlt(_localctx, 13);
				{
				setState(1155);
				match(ViewKeyword);
				}
				break;
			case ConstructorKeyword:
				enterOuterAlt(_localctx, 14);
				{
				setState(1156);
				match(ConstructorKeyword);
				}
				break;
			case FallbackKeyword:
				enterOuterAlt(_localctx, 15);
				{
				setState(1157);
				match(FallbackKeyword);
				}
				break;
			case ReceiveKeyword:
				enterOuterAlt(_localctx, 16);
				{
				setState(1158);
				match(ReceiveKeyword);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class OverrideSpecifierContext extends ParserRuleContext {
		public List<UserDefinedTypeNameContext> userDefinedTypeName() {
			return getRuleContexts(UserDefinedTypeNameContext.class);
		}
		public UserDefinedTypeNameContext userDefinedTypeName(int i) {
			return getRuleContext(UserDefinedTypeNameContext.class,i);
		}
		public OverrideSpecifierContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_overrideSpecifier; }
	}

	public final OverrideSpecifierContext overrideSpecifier() throws RecognitionException {
		OverrideSpecifierContext _localctx = new OverrideSpecifierContext(_ctx, getState());
		enterRule(_localctx, 196, RULE_overrideSpecifier);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(1161);
			match(T__97);
			setState(1173);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__22) {
				{
				setState(1162);
				match(T__22);
				setState(1163);
				userDefinedTypeName();
				setState(1168);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==T__15) {
					{
					{
					setState(1164);
					match(T__15);
					setState(1165);
					userDefinedTypeName();
					}
					}
					setState(1170);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				setState(1171);
				match(T__23);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StringLiteralContext extends ParserRuleContext {
		public List<TerminalNode> StringLiteralFragment() { return getTokens(SolidityParser.StringLiteralFragment); }
		public TerminalNode StringLiteralFragment(int i) {
			return getToken(SolidityParser.StringLiteralFragment, i);
		}
		public StringLiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_stringLiteral; }
	}

	public final StringLiteralContext stringLiteral() throws RecognitionException {
		StringLiteralContext _localctx = new StringLiteralContext(_ctx, getState());
		enterRule(_localctx, 198, RULE_stringLiteral);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(1176); 
			_errHandler.sync(this);
			_alt = 1;
			do {
				switch (_alt) {
				case 1:
					{
					{
					setState(1175);
					match(StringLiteralFragment);
					}
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				setState(1178); 
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,132,_ctx);
			} while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER );
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public boolean sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 34:
			return typeName_sempred((TypeNameContext)_localctx, predIndex);
		case 64:
			return expression_sempred((ExpressionContext)_localctx, predIndex);
		}
		return true;
	}
	private boolean typeName_sempred(TypeNameContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0:
			return precpred(_ctx, 3);
		}
		return true;
	}
	private boolean expression_sempred(ExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 1:
			return precpred(_ctx, 14);
		case 2:
			return precpred(_ctx, 13);
		case 3:
			return precpred(_ctx, 12);
		case 4:
			return precpred(_ctx, 11);
		case 5:
			return precpred(_ctx, 10);
		case 6:
			return precpred(_ctx, 9);
		case 7:
			return precpred(_ctx, 8);
		case 8:
			return precpred(_ctx, 7);
		case 9:
			return precpred(_ctx, 6);
		case 10:
			return precpred(_ctx, 5);
		case 11:
			return precpred(_ctx, 4);
		case 12:
			return precpred(_ctx, 3);
		case 13:
			return precpred(_ctx, 2);
		case 14:
			return precpred(_ctx, 29);
		case 15:
			return precpred(_ctx, 27);
		case 16:
			return precpred(_ctx, 26);
		case 17:
			return precpred(_ctx, 25);
		case 18:
			return precpred(_ctx, 22);
		case 19:
			return precpred(_ctx, 21);
		}
		return true;
	}

	public static final String _serializedATN =
		"\u0004\u0001\u0086\u049d\u0002\u0000\u0007\u0000\u0002\u0001\u0007\u0001"+
		"\u0002\u0002\u0007\u0002\u0002\u0003\u0007\u0003\u0002\u0004\u0007\u0004"+
		"\u0002\u0005\u0007\u0005\u0002\u0006\u0007\u0006\u0002\u0007\u0007\u0007"+
		"\u0002\b\u0007\b\u0002\t\u0007\t\u0002\n\u0007\n\u0002\u000b\u0007\u000b"+
		"\u0002\f\u0007\f\u0002\r\u0007\r\u0002\u000e\u0007\u000e\u0002\u000f\u0007"+
		"\u000f\u0002\u0010\u0007\u0010\u0002\u0011\u0007\u0011\u0002\u0012\u0007"+
		"\u0012\u0002\u0013\u0007\u0013\u0002\u0014\u0007\u0014\u0002\u0015\u0007"+
		"\u0015\u0002\u0016\u0007\u0016\u0002\u0017\u0007\u0017\u0002\u0018\u0007"+
		"\u0018\u0002\u0019\u0007\u0019\u0002\u001a\u0007\u001a\u0002\u001b\u0007"+
		"\u001b\u0002\u001c\u0007\u001c\u0002\u001d\u0007\u001d\u0002\u001e\u0007"+
		"\u001e\u0002\u001f\u0007\u001f\u0002 \u0007 \u0002!\u0007!\u0002\"\u0007"+
		"\"\u0002#\u0007#\u0002$\u0007$\u0002%\u0007%\u0002&\u0007&\u0002\'\u0007"+
		"\'\u0002(\u0007(\u0002)\u0007)\u0002*\u0007*\u0002+\u0007+\u0002,\u0007"+
		",\u0002-\u0007-\u0002.\u0007.\u0002/\u0007/\u00020\u00070\u00021\u0007"+
		"1\u00022\u00072\u00023\u00073\u00024\u00074\u00025\u00075\u00026\u0007"+
		"6\u00027\u00077\u00028\u00078\u00029\u00079\u0002:\u0007:\u0002;\u0007"+
		";\u0002<\u0007<\u0002=\u0007=\u0002>\u0007>\u0002?\u0007?\u0002@\u0007"+
		"@\u0002A\u0007A\u0002B\u0007B\u0002C\u0007C\u0002D\u0007D\u0002E\u0007"+
		"E\u0002F\u0007F\u0002G\u0007G\u0002H\u0007H\u0002I\u0007I\u0002J\u0007"+
		"J\u0002K\u0007K\u0002L\u0007L\u0002M\u0007M\u0002N\u0007N\u0002O\u0007"+
		"O\u0002P\u0007P\u0002Q\u0007Q\u0002R\u0007R\u0002S\u0007S\u0002T\u0007"+
		"T\u0002U\u0007U\u0002V\u0007V\u0002W\u0007W\u0002X\u0007X\u0002Y\u0007"+
		"Y\u0002Z\u0007Z\u0002[\u0007[\u0002\\\u0007\\\u0002]\u0007]\u0002^\u0007"+
		"^\u0002_\u0007_\u0002`\u0007`\u0002a\u0007a\u0002b\u0007b\u0002c\u0007"+
		"c\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000"+
		"\u0001\u0000\u0001\u0000\u0005\u0000\u00d1\b\u0000\n\u0000\f\u0000\u00d4"+
		"\t\u0000\u0001\u0000\u0001\u0000\u0001\u0001\u0001\u0001\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0002\u0001\u0002\u0001\u0003\u0001\u0003\u0003"+
		"\u0003\u00e1\b\u0003\u0001\u0004\u0001\u0004\u0003\u0004\u00e5\b\u0004"+
		"\u0001\u0004\u0005\u0004\u00e8\b\u0004\n\u0004\f\u0004\u00eb\t\u0004\u0001"+
		"\u0005\u0001\u0005\u0001\u0006\u0003\u0006\u00f0\b\u0006\u0001\u0006\u0001"+
		"\u0006\u0003\u0006\u00f4\b\u0006\u0001\u0006\u0003\u0006\u00f7\b\u0006"+
		"\u0001\u0007\u0001\u0007\u0001\u0007\u0003\u0007\u00fc\b\u0007\u0001\b"+
		"\u0001\b\u0001\b\u0001\b\u0003\b\u0102\b\b\u0001\b\u0001\b\u0001\b\u0001"+
		"\b\u0001\b\u0003\b\u0109\b\b\u0001\b\u0001\b\u0003\b\u010d\b\b\u0001\b"+
		"\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0005"+
		"\b\u0118\b\b\n\b\f\b\u011b\t\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b"+
		"\u0003\b\u0122\b\b\u0001\t\u0001\t\u0001\n\u0003\n\u0127\b\n\u0001\n\u0001"+
		"\n\u0001\n\u0001\n\u0001\n\u0001\n\u0005\n\u012f\b\n\n\n\f\n\u0132\t\n"+
		"\u0003\n\u0134\b\n\u0001\n\u0001\n\u0005\n\u0138\b\n\n\n\f\n\u013b\t\n"+
		"\u0001\n\u0001\n\u0001\u000b\u0001\u000b\u0001\u000b\u0003\u000b\u0142"+
		"\b\u000b\u0001\u000b\u0003\u000b\u0145\b\u000b\u0001\f\u0001\f\u0001\f"+
		"\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0003\f\u014f\b\f\u0001\r\u0001"+
		"\r\u0001\r\u0001\r\u0001\r\u0001\r\u0001\r\u0005\r\u0158\b\r\n\r\f\r\u015b"+
		"\t\r\u0001\r\u0001\r\u0001\r\u0003\r\u0160\b\r\u0001\r\u0001\r\u0001\u000e"+
		"\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000e"+
		"\u0001\u000f\u0001\u000f\u0001\u000f\u0001\u000f\u0001\u000f\u0001\u0010"+
		"\u0001\u0010\u0001\u0010\u0001\u0010\u0001\u0010\u0003\u0010\u0175\b\u0010"+
		"\u0001\u0010\u0001\u0010\u0001\u0011\u0001\u0011\u0001\u0011\u0001\u0011"+
		"\u0001\u0011\u0001\u0011\u0001\u0011\u0001\u0011\u0005\u0011\u0181\b\u0011"+
		"\n\u0011\f\u0011\u0184\t\u0011\u0003\u0011\u0186\b\u0011\u0001\u0011\u0001"+
		"\u0011\u0001\u0012\u0001\u0012\u0001\u0012\u0003\u0012\u018d\b\u0012\u0001"+
		"\u0012\u0001\u0012\u0005\u0012\u0191\b\u0012\n\u0012\f\u0012\u0194\t\u0012"+
		"\u0001\u0012\u0001\u0012\u0003\u0012\u0198\b\u0012\u0001\u0013\u0001\u0013"+
		"\u0001\u0013\u0003\u0013\u019d\b\u0013\u0001\u0013\u0003\u0013\u01a0\b"+
		"\u0013\u0001\u0014\u0001\u0014\u0001\u0014\u0001\u0014\u0003\u0014\u01a6"+
		"\b\u0014\u0001\u0014\u0001\u0014\u0003\u0014\u01aa\b\u0014\u0001\u0015"+
		"\u0001\u0015\u0003\u0015\u01ae\b\u0015\u0001\u0015\u0001\u0015\u0001\u0015"+
		"\u0003\u0015\u01b3\b\u0015\u0001\u0016\u0001\u0016\u0001\u0016\u0001\u0017"+
		"\u0001\u0017\u0001\u0017\u0001\u0017\u0001\u0017\u0005\u0017\u01bd\b\u0017"+
		"\n\u0017\f\u0017\u01c0\t\u0017\u0001\u0018\u0001\u0018\u0001\u0018\u0001"+
		"\u0018\u0003\u0018\u01c6\b\u0018\u0001\u0018\u0001\u0018\u0001\u0019\u0001"+
		"\u0019\u0001\u001a\u0001\u001a\u0001\u001a\u0001\u001a\u0003\u001a\u01d0"+
		"\b\u001a\u0001\u001a\u0001\u001a\u0005\u001a\u01d4\b\u001a\n\u001a\f\u001a"+
		"\u01d7\t\u001a\u0001\u001a\u0001\u001a\u0001\u001b\u0001\u001b\u0001\u001b"+
		"\u0001\u001b\u0005\u001b\u01df\b\u001b\n\u001b\f\u001b\u01e2\t\u001b\u0003"+
		"\u001b\u01e4\b\u001b\u0001\u001b\u0001\u001b\u0001\u001c\u0001\u001c\u0003"+
		"\u001c\u01ea\b\u001c\u0001\u001c\u0003\u001c\u01ed\b\u001c\u0001\u001d"+
		"\u0001\u001d\u0001\u001d\u0001\u001d\u0005\u001d\u01f3\b\u001d\n\u001d"+
		"\f\u001d\u01f6\t\u001d\u0003\u001d\u01f8\b\u001d\u0001\u001d\u0001\u001d"+
		"\u0001\u001e\u0001\u001e\u0003\u001e\u01fe\b\u001e\u0001\u001e\u0003\u001e"+
		"\u0201\b\u001e\u0001\u001f\u0001\u001f\u0001\u001f\u0001\u001f\u0005\u001f"+
		"\u0207\b\u001f\n\u001f\f\u001f\u020a\t\u001f\u0003\u001f\u020c\b\u001f"+
		"\u0001\u001f\u0001\u001f\u0001 \u0001 \u0003 \u0212\b \u0001!\u0001!\u0003"+
		"!\u0216\b!\u0001!\u0001!\u0001\"\u0001\"\u0001\"\u0001\"\u0001\"\u0001"+
		"\"\u0001\"\u0003\"\u0221\b\"\u0001\"\u0001\"\u0001\"\u0003\"\u0226\b\""+
		"\u0001\"\u0005\"\u0229\b\"\n\"\f\"\u022c\t\"\u0001#\u0001#\u0001#\u0005"+
		"#\u0231\b#\n#\f#\u0234\t#\u0001$\u0001$\u0003$\u0238\b$\u0001%\u0001%"+
		"\u0001%\u0001%\u0001%\u0001%\u0001%\u0001&\u0001&\u0001&\u0001&\u0001"+
		"&\u0005&\u0246\b&\n&\f&\u0249\t&\u0001&\u0001&\u0003&\u024d\b&\u0001\'"+
		"\u0001\'\u0001(\u0001(\u0001)\u0001)\u0005)\u0255\b)\n)\f)\u0258\t)\u0001"+
		")\u0001)\u0001*\u0001*\u0001*\u0001*\u0001*\u0001*\u0001*\u0001*\u0001"+
		"*\u0001*\u0001*\u0001*\u0001*\u0001*\u0001*\u0001*\u0003*\u026c\b*\u0001"+
		"+\u0001+\u0001+\u0001,\u0001,\u0001,\u0001,\u0001,\u0001,\u0001,\u0003"+
		",\u0278\b,\u0001-\u0001-\u0001-\u0003-\u027d\b-\u0001-\u0001-\u0004-\u0281"+
		"\b-\u000b-\f-\u0282\u0001.\u0001.\u0003.\u0287\b.\u0001.\u0003.\u028a"+
		"\b.\u0001.\u0001.\u0001/\u0001/\u0001/\u0001/\u0001/\u0001/\u00010\u0001"+
		"0\u00030\u0296\b0\u00011\u00011\u00011\u00012\u00012\u00032\u029d\b2\u0001"+
		"3\u00013\u00013\u00013\u00033\u02a3\b3\u00013\u00013\u00033\u02a7\b3\u0001"+
		"3\u00033\u02aa\b3\u00013\u00013\u00013\u00014\u00014\u00034\u02b1\b4\u0001"+
		"4\u00014\u00015\u00015\u00015\u00015\u00015\u00015\u00015\u00015\u0001"+
		"6\u00016\u00016\u00017\u00017\u00017\u00018\u00018\u00038\u02c5\b8\u0001"+
		"8\u00018\u00019\u00019\u00019\u0001:\u0001:\u0001:\u0001:\u0001;\u0001"+
		";\u0001;\u0001;\u0001<\u0001<\u0001<\u0001<\u0001<\u0001<\u0001<\u0003"+
		"<\u02db\b<\u0001<\u0001<\u0003<\u02df\b<\u0001<\u0001<\u0001=\u0003=\u02e4"+
		"\b=\u0001=\u0001=\u0003=\u02e8\b=\u0005=\u02ea\b=\n=\f=\u02ed\t=\u0001"+
		">\u0001>\u0003>\u02f1\b>\u0001>\u0005>\u02f4\b>\n>\f>\u02f7\t>\u0001>"+
		"\u0003>\u02fa\b>\u0001>\u0001>\u0001?\u0001?\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0003@\u031c\b@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0003@\u034d\b@\u0001@\u0001@\u0001@\u0001@\u0003"+
		"@\u0353\b@\u0001@\u0001@\u0003@\u0357\b@\u0001@\u0001@\u0001@\u0001@\u0001"+
		"@\u0001@\u0001@\u0001@\u0001@\u0001@\u0001@\u0003@\u0364\b@\u0001@\u0001"+
		"@\u0001@\u0001@\u0005@\u036a\b@\n@\f@\u036d\t@\u0001A\u0001A\u0001A\u0001"+
		"A\u0001A\u0001A\u0001A\u0001A\u0001A\u0003A\u0378\bA\u0001A\u0001A\u0001"+
		"A\u0003A\u037d\bA\u0001A\u0003A\u0380\bA\u0001B\u0001B\u0001B\u0005B\u0385"+
		"\bB\nB\fB\u0388\tB\u0001C\u0001C\u0001C\u0005C\u038d\bC\nC\fC\u0390\t"+
		"C\u0001C\u0003C\u0393\bC\u0001D\u0001D\u0001D\u0001D\u0001E\u0001E\u0003"+
		"E\u039b\bE\u0001E\u0001E\u0001F\u0001F\u0003F\u03a1\bF\u0001F\u0001F\u0003"+
		"F\u03a5\bF\u0003F\u03a7\bF\u0001G\u0001G\u0001G\u0001G\u0001G\u0001H\u0001"+
		"H\u0005H\u03b0\bH\nH\fH\u03b3\tH\u0001H\u0001H\u0001I\u0001I\u0001I\u0001"+
		"I\u0001I\u0001I\u0001I\u0001I\u0001I\u0001I\u0001I\u0001I\u0001I\u0001"+
		"I\u0001I\u0001I\u0001I\u0001I\u0003I\u03c9\bI\u0001J\u0001J\u0001J\u0003"+
		"J\u03ce\bJ\u0001K\u0001K\u0001K\u0001K\u0001L\u0001L\u0001L\u0001L\u0003"+
		"L\u03d8\bL\u0001L\u0001L\u0003L\u03dc\bL\u0001L\u0001L\u0005L\u03e0\b"+
		"L\nL\fL\u03e3\tL\u0001L\u0003L\u03e6\bL\u0001M\u0001M\u0001M\u0001M\u0003"+
		"M\u03ec\bM\u0001N\u0001N\u0001N\u0001N\u0001O\u0001O\u0001O\u0001O\u0001"+
		"O\u0001O\u0003O\u03f8\bO\u0001P\u0001P\u0001P\u0005P\u03fd\bP\nP\fP\u0400"+
		"\tP\u0001Q\u0001Q\u0001Q\u0001R\u0001R\u0001R\u0001S\u0001S\u0001S\u0005"+
		"S\u040b\bS\nS\fS\u040e\tS\u0001T\u0001T\u0001T\u0001T\u0001T\u0001T\u0003"+
		"T\u0416\bT\u0001U\u0001U\u0001U\u0001U\u0003U\u041c\bU\u0001U\u0001U\u0003"+
		"U\u0420\bU\u0001U\u0001U\u0001V\u0001V\u0001V\u0001W\u0001W\u0001W\u0003"+
		"W\u042a\bW\u0001W\u0001W\u0001W\u0003W\u042f\bW\u0001W\u0001W\u0001X\u0001"+
		"X\u0001X\u0001X\u0001Y\u0001Y\u0001Y\u0001Y\u0003Y\u043b\bY\u0001Z\u0001"+
		"Z\u0001Z\u0001Z\u0001[\u0001[\u0003[\u0443\b[\u0001[\u0001[\u0003[\u0447"+
		"\b[\u0005[\u0449\b[\n[\f[\u044c\t[\u0003[\u044e\b[\u0001[\u0001[\u0001"+
		"[\u0001[\u0001[\u0005[\u0455\b[\n[\f[\u0458\t[\u0003[\u045a\b[\u0001["+
		"\u0003[\u045d\b[\u0001\\\u0001\\\u0003\\\u0461\b\\\u0001]\u0001]\u0003"+
		"]\u0465\b]\u0001^\u0001^\u0001^\u0001^\u0001^\u0001^\u0001^\u0001^\u0003"+
		"^\u046f\b^\u0001_\u0004_\u0472\b_\u000b_\f_\u0473\u0001`\u0001`\u0001"+
		"a\u0001a\u0001a\u0001a\u0001a\u0001a\u0001a\u0001a\u0001a\u0001a\u0001"+
		"a\u0001a\u0001a\u0001a\u0001a\u0001a\u0003a\u0488\ba\u0001b\u0001b\u0001"+
		"b\u0001b\u0001b\u0005b\u048f\bb\nb\fb\u0492\tb\u0001b\u0001b\u0003b\u0496"+
		"\bb\u0001c\u0004c\u0499\bc\u000bc\fc\u049a\u0001c\u0000\u0002D\u0080d"+
		"\u0000\u0002\u0004\u0006\b\n\f\u000e\u0010\u0012\u0014\u0016\u0018\u001a"+
		"\u001c\u001e \"$&(*,.02468:<>@BDFHJLNPRTVXZ\\^`bdfhjlnprtvxz|~\u0080\u0082"+
		"\u0084\u0086\u0088\u008a\u008c\u008e\u0090\u0092\u0094\u0096\u0098\u009a"+
		"\u009c\u009e\u00a0\u00a2\u00a4\u00a6\u00a8\u00aa\u00ac\u00ae\u00b0\u00b2"+
		"\u00b4\u00b6\u00b8\u00ba\u00bc\u00be\u00c0\u00c2\u00c4\u00c6\u0000\u000f"+
		"\u0001\u0000\u0004\n\u0001\u0000\u0013\u0015\u0001\u0000(*\u0004\u0000"+
		"ppww{{}}\u0003\u0000$$8;cg\u0001\u0000<=\u0001\u0000@A\u0001\u0000BC\u0002"+
		"\u0000\r\rFG\u0001\u0000HI\u0001\u0000\u0006\t\u0001\u0000LM\u0002\u0000"+
		"\n\nPY\u0001\u0000ij\u0003\u0000ttvvxy\u0530\u0000\u00d2\u0001\u0000\u0000"+
		"\u0000\u0002\u00d7\u0001\u0000\u0000\u0000\u0004\u00dc\u0001\u0000\u0000"+
		"\u0000\u0006\u00e0\u0001\u0000\u0000\u0000\b\u00e2\u0001\u0000\u0000\u0000"+
		"\n\u00ec\u0001\u0000\u0000\u0000\f\u00f6\u0001\u0000\u0000\u0000\u000e"+
		"\u00f8\u0001\u0000\u0000\u0000\u0010\u0121\u0001\u0000\u0000\u0000\u0012"+
		"\u0123\u0001\u0000\u0000\u0000\u0014\u0126\u0001\u0000\u0000\u0000\u0016"+
		"\u013e\u0001\u0000\u0000\u0000\u0018\u014e\u0001\u0000\u0000\u0000\u001a"+
		"\u0150\u0001\u0000\u0000\u0000\u001c\u0163\u0001\u0000\u0000\u0000\u001e"+
		"\u016a\u0001\u0000\u0000\u0000 \u016f\u0001\u0000\u0000\u0000\"\u0178"+
		"\u0001\u0000\u0000\u0000$\u0189\u0001\u0000\u0000\u0000&\u0199\u0001\u0000"+
		"\u0000\u0000(\u01a1\u0001\u0000\u0000\u0000*\u01b2\u0001\u0000\u0000\u0000"+
		",\u01b4\u0001\u0000\u0000\u0000.\u01be\u0001\u0000\u0000\u00000\u01c1"+
		"\u0001\u0000\u0000\u00002\u01c9\u0001\u0000\u0000\u00004\u01cb\u0001\u0000"+
		"\u0000\u00006\u01da\u0001\u0000\u0000\u00008\u01e7\u0001\u0000\u0000\u0000"+
		":\u01ee\u0001\u0000\u0000\u0000<\u01fb\u0001\u0000\u0000\u0000>\u0202"+
		"\u0001\u0000\u0000\u0000@\u020f\u0001\u0000\u0000\u0000B\u0213\u0001\u0000"+
		"\u0000\u0000D\u0220\u0001\u0000\u0000\u0000F\u022d\u0001\u0000\u0000\u0000"+
		"H\u0237\u0001\u0000\u0000\u0000J\u0239\u0001\u0000\u0000\u0000L\u0240"+
		"\u0001\u0000\u0000\u0000N\u024e\u0001\u0000\u0000\u0000P\u0250\u0001\u0000"+
		"\u0000\u0000R\u0252\u0001\u0000\u0000\u0000T\u026b\u0001\u0000\u0000\u0000"+
		"V\u026d\u0001\u0000\u0000\u0000X\u0270\u0001\u0000\u0000\u0000Z\u0279"+
		"\u0001\u0000\u0000\u0000\\\u0284\u0001\u0000\u0000\u0000^\u028d\u0001"+
		"\u0000\u0000\u0000`\u0295\u0001\u0000\u0000\u0000b\u0297\u0001\u0000\u0000"+
		"\u0000d\u029a\u0001\u0000\u0000\u0000f\u029e\u0001\u0000\u0000\u0000h"+
		"\u02ae\u0001\u0000\u0000\u0000j\u02b4\u0001\u0000\u0000\u0000l\u02bc\u0001"+
		"\u0000\u0000\u0000n\u02bf\u0001\u0000\u0000\u0000p\u02c2\u0001\u0000\u0000"+
		"\u0000r\u02c8\u0001\u0000\u0000\u0000t\u02cb\u0001\u0000\u0000\u0000v"+
		"\u02cf\u0001\u0000\u0000\u0000x\u02da\u0001\u0000\u0000\u0000z\u02e3\u0001"+
		"\u0000\u0000\u0000|\u02ee\u0001\u0000\u0000\u0000~\u02fd\u0001\u0000\u0000"+
		"\u0000\u0080\u031b\u0001\u0000\u0000\u0000\u0082\u037f\u0001\u0000\u0000"+
		"\u0000\u0084\u0381\u0001\u0000\u0000\u0000\u0086\u0389\u0001\u0000\u0000"+
		"\u0000\u0088\u0394\u0001\u0000\u0000\u0000\u008a\u0398\u0001\u0000\u0000"+
		"\u0000\u008c\u03a6\u0001\u0000\u0000\u0000\u008e\u03a8\u0001\u0000\u0000"+
		"\u0000\u0090\u03ad\u0001\u0000\u0000\u0000\u0092\u03c8\u0001\u0000\u0000"+
		"\u0000\u0094\u03cd\u0001\u0000\u0000\u0000\u0096\u03cf\u0001\u0000\u0000"+
		"\u0000\u0098\u03d7\u0001\u0000\u0000\u0000\u009a\u03e7\u0001\u0000\u0000"+
		"\u0000\u009c\u03ed\u0001\u0000\u0000\u0000\u009e\u03f7\u0001\u0000\u0000"+
		"\u0000\u00a0\u03f9\u0001\u0000\u0000\u0000\u00a2\u0401\u0001\u0000\u0000"+
		"\u0000\u00a4\u0404\u0001\u0000\u0000\u0000\u00a6\u0407\u0001\u0000\u0000"+
		"\u0000\u00a8\u0415\u0001\u0000\u0000\u0000\u00aa\u0417\u0001\u0000\u0000"+
		"\u0000\u00ac\u0423\u0001\u0000\u0000\u0000\u00ae\u0426\u0001\u0000\u0000"+
		"\u0000\u00b0\u0432\u0001\u0000\u0000\u0000\u00b2\u043a\u0001\u0000\u0000"+
		"\u0000\u00b4\u043c\u0001\u0000\u0000\u0000\u00b6\u045c\u0001\u0000\u0000"+
		"\u0000\u00b8\u0460\u0001\u0000\u0000\u0000\u00ba\u0462\u0001\u0000\u0000"+
		"\u0000\u00bc\u046e\u0001\u0000\u0000\u0000\u00be\u0471\u0001\u0000\u0000"+
		"\u0000\u00c0\u0475\u0001\u0000\u0000\u0000\u00c2\u0487\u0001\u0000\u0000"+
		"\u0000\u00c4\u0489\u0001\u0000\u0000\u0000\u00c6\u0498\u0001\u0000\u0000"+
		"\u0000\u00c8\u00d1\u0003\u0002\u0001\u0000\u00c9\u00d1\u0003\u0010\b\u0000"+
		"\u00ca\u00d1\u0003\u0014\n\u0000\u00cb\u00d1\u00034\u001a\u0000\u00cc"+
		"\u00d1\u0003\"\u0011\u0000\u00cd\u00d1\u0003(\u0014\u0000\u00ce\u00d1"+
		"\u0003\u001c\u000e\u0000\u00cf\u00d1\u0003\u001e\u000f\u0000\u00d0\u00c8"+
		"\u0001\u0000\u0000\u0000\u00d0\u00c9\u0001\u0000\u0000\u0000\u00d0\u00ca"+
		"\u0001\u0000\u0000\u0000\u00d0\u00cb\u0001\u0000\u0000\u0000\u00d0\u00cc"+
		"\u0001\u0000\u0000\u0000\u00d0\u00cd\u0001\u0000\u0000\u0000\u00d0\u00ce"+
		"\u0001\u0000\u0000\u0000\u00d0\u00cf\u0001\u0000\u0000\u0000\u00d1\u00d4"+
		"\u0001\u0000\u0000\u0000\u00d2\u00d0\u0001\u0000\u0000\u0000\u00d2\u00d3"+
		"\u0001\u0000\u0000\u0000\u00d3\u00d5\u0001\u0000\u0000\u0000\u00d4\u00d2"+
		"\u0001\u0000\u0000\u0000\u00d5\u00d6\u0005\u0000\u0000\u0001\u00d6\u0001"+
		"\u0001\u0000\u0000\u0000\u00d7\u00d8\u0005\u0001\u0000\u0000\u00d8\u00d9"+
		"\u0003\u0004\u0002\u0000\u00d9\u00da\u0003\u0006\u0003\u0000\u00da\u00db"+
		"\u0005\u0002\u0000\u0000\u00db\u0003\u0001\u0000\u0000\u0000\u00dc\u00dd"+
		"\u0003\u00bc^\u0000\u00dd\u0005\u0001\u0000\u0000\u0000\u00de\u00e1\u0003"+
		"\b\u0004\u0000\u00df\u00e1\u0003\u0080@\u0000\u00e0\u00de\u0001\u0000"+
		"\u0000\u0000\u00e0\u00df\u0001\u0000\u0000\u0000\u00e1\u0007\u0001\u0000"+
		"\u0000\u0000\u00e2\u00e9\u0003\f\u0006\u0000\u00e3\u00e5\u0005\u0003\u0000"+
		"\u0000\u00e4\u00e3\u0001\u0000\u0000\u0000\u00e4\u00e5\u0001\u0000\u0000"+
		"\u0000\u00e5\u00e6\u0001\u0000\u0000\u0000\u00e6\u00e8\u0003\f\u0006\u0000"+
		"\u00e7\u00e4\u0001\u0000\u0000\u0000\u00e8\u00eb\u0001\u0000\u0000\u0000"+
		"\u00e9\u00e7\u0001\u0000\u0000\u0000\u00e9\u00ea\u0001\u0000\u0000\u0000"+
		"\u00ea\t\u0001\u0000\u0000\u0000\u00eb\u00e9\u0001\u0000\u0000\u0000\u00ec"+
		"\u00ed\u0007\u0000\u0000\u0000\u00ed\u000b\u0001\u0000\u0000\u0000\u00ee"+
		"\u00f0\u0003\n\u0005\u0000\u00ef\u00ee\u0001\u0000\u0000\u0000\u00ef\u00f0"+
		"\u0001\u0000\u0000\u0000\u00f0\u00f1\u0001\u0000\u0000\u0000\u00f1\u00f7"+
		"\u0005\u0083\u0000\u0000\u00f2\u00f4\u0003\n\u0005\u0000\u00f3\u00f2\u0001"+
		"\u0000\u0000\u0000\u00f3\u00f4\u0001\u0000\u0000\u0000\u00f4\u00f5\u0001"+
		"\u0000\u0000\u0000\u00f5\u00f7\u0005i\u0000\u0000\u00f6\u00ef\u0001\u0000"+
		"\u0000\u0000\u00f6\u00f3\u0001\u0000\u0000\u0000\u00f7\r\u0001\u0000\u0000"+
		"\u0000\u00f8\u00fb\u0003\u00bc^\u0000\u00f9\u00fa\u0005\u000b\u0000\u0000"+
		"\u00fa\u00fc\u0003\u00bc^\u0000\u00fb\u00f9\u0001\u0000\u0000\u0000\u00fb"+
		"\u00fc\u0001\u0000\u0000\u0000\u00fc\u000f\u0001\u0000\u0000\u0000\u00fd"+
		"\u00fe\u0005\f\u0000\u0000\u00fe\u0101\u0003\u0012\t\u0000\u00ff\u0100"+
		"\u0005\u000b\u0000\u0000\u0100\u0102\u0003\u00bc^\u0000\u0101\u00ff\u0001"+
		"\u0000\u0000\u0000\u0101\u0102\u0001\u0000\u0000\u0000\u0102\u0103\u0001"+
		"\u0000\u0000\u0000\u0103\u0104\u0005\u0002\u0000\u0000\u0104\u0122\u0001"+
		"\u0000\u0000\u0000\u0105\u0108\u0005\f\u0000\u0000\u0106\u0109\u0005\r"+
		"\u0000\u0000\u0107\u0109\u0003\u00bc^\u0000\u0108\u0106\u0001\u0000\u0000"+
		"\u0000\u0108\u0107\u0001\u0000\u0000\u0000\u0109\u010c\u0001\u0000\u0000"+
		"\u0000\u010a\u010b\u0005\u000b\u0000\u0000\u010b\u010d\u0003\u00bc^\u0000"+
		"\u010c\u010a\u0001\u0000\u0000\u0000\u010c\u010d\u0001\u0000\u0000\u0000"+
		"\u010d\u010e\u0001\u0000\u0000\u0000\u010e\u010f\u0005\u000e\u0000\u0000"+
		"\u010f\u0110\u0003\u0012\t\u0000\u0110\u0111\u0005\u0002\u0000\u0000\u0111"+
		"\u0122\u0001\u0000\u0000\u0000\u0112\u0113\u0005\f\u0000\u0000\u0113\u0114"+
		"\u0005\u000f\u0000\u0000\u0114\u0119\u0003\u000e\u0007\u0000\u0115\u0116"+
		"\u0005\u0010\u0000\u0000\u0116\u0118\u0003\u000e\u0007\u0000\u0117\u0115"+
		"\u0001\u0000\u0000\u0000\u0118\u011b\u0001\u0000\u0000\u0000\u0119\u0117"+
		"\u0001\u0000\u0000\u0000\u0119\u011a\u0001\u0000\u0000\u0000\u011a\u011c"+
		"\u0001\u0000\u0000\u0000\u011b\u0119\u0001\u0000\u0000\u0000\u011c\u011d"+
		"\u0005\u0011\u0000\u0000\u011d\u011e\u0005\u000e\u0000\u0000\u011e\u011f"+
		"\u0003\u0012\t\u0000\u011f\u0120\u0005\u0002\u0000\u0000\u0120\u0122\u0001"+
		"\u0000\u0000\u0000\u0121\u00fd\u0001\u0000\u0000\u0000\u0121\u0105\u0001"+
		"\u0000\u0000\u0000\u0121\u0112\u0001\u0000\u0000\u0000\u0122\u0011\u0001"+
		"\u0000\u0000\u0000\u0123\u0124\u0005\u0082\u0000\u0000\u0124\u0013\u0001"+
		"\u0000\u0000\u0000\u0125\u0127\u0005\u0012\u0000\u0000\u0126\u0125\u0001"+
		"\u0000\u0000\u0000\u0126\u0127\u0001\u0000\u0000\u0000\u0127\u0128\u0001"+
		"\u0000\u0000\u0000\u0128\u0129\u0007\u0001\u0000\u0000\u0129\u0133\u0003"+
		"\u00bc^\u0000\u012a\u012b\u0005\u0016\u0000\u0000\u012b\u0130\u0003\u0016"+
		"\u000b\u0000\u012c\u012d\u0005\u0010\u0000\u0000\u012d\u012f\u0003\u0016"+
		"\u000b\u0000\u012e\u012c\u0001\u0000\u0000\u0000\u012f\u0132\u0001\u0000"+
		"\u0000\u0000\u0130\u012e\u0001\u0000\u0000\u0000\u0130\u0131\u0001\u0000"+
		"\u0000\u0000\u0131\u0134\u0001\u0000\u0000\u0000\u0132\u0130\u0001\u0000"+
		"\u0000\u0000\u0133\u012a\u0001\u0000\u0000\u0000\u0133\u0134\u0001\u0000"+
		"\u0000\u0000\u0134\u0135\u0001\u0000\u0000\u0000\u0135\u0139\u0005\u000f"+
		"\u0000\u0000\u0136\u0138\u0003\u0018\f\u0000\u0137\u0136\u0001\u0000\u0000"+
		"\u0000\u0138\u013b\u0001\u0000\u0000\u0000\u0139\u0137\u0001\u0000\u0000"+
		"\u0000\u0139\u013a\u0001\u0000\u0000\u0000\u013a\u013c\u0001\u0000\u0000"+
		"\u0000\u013b\u0139\u0001\u0000\u0000\u0000\u013c\u013d\u0005\u0011\u0000"+
		"\u0000\u013d\u0015\u0001\u0000\u0000\u0000\u013e\u0144\u0003F#\u0000\u013f"+
		"\u0141\u0005\u0017\u0000\u0000\u0140\u0142\u0003\u0084B\u0000\u0141\u0140"+
		"\u0001\u0000\u0000\u0000\u0141\u0142\u0001\u0000\u0000\u0000\u0142\u0143"+
		"\u0001\u0000\u0000\u0000\u0143\u0145\u0005\u0018\u0000\u0000\u0144\u013f"+
		"\u0001\u0000\u0000\u0000\u0144\u0145\u0001\u0000\u0000\u0000\u0145\u0017"+
		"\u0001\u0000\u0000\u0000\u0146\u014f\u0003\u001a\r\u0000\u0147\u014f\u0003"+
		" \u0010\u0000\u0148\u014f\u0003\"\u0011\u0000\u0149\u014f\u0003$\u0012"+
		"\u0000\u014a\u014f\u0003(\u0014\u0000\u014b\u014f\u00030\u0018\u0000\u014c"+
		"\u014f\u00034\u001a\u0000\u014d\u014f\u0003\u001e\u000f\u0000\u014e\u0146"+
		"\u0001\u0000\u0000\u0000\u014e\u0147\u0001\u0000\u0000\u0000\u014e\u0148"+
		"\u0001\u0000\u0000\u0000\u014e\u0149\u0001\u0000\u0000\u0000\u014e\u014a"+
		"\u0001\u0000\u0000\u0000\u014e\u014b\u0001\u0000\u0000\u0000\u014e\u014c"+
		"\u0001\u0000\u0000\u0000\u014e\u014d\u0001\u0000\u0000\u0000\u014f\u0019"+
		"\u0001\u0000\u0000\u0000\u0150\u0159\u0003D\"\u0000\u0151\u0158\u0005"+
		"y\u0000\u0000\u0152\u0158\u0005v\u0000\u0000\u0153\u0158\u0005x\u0000"+
		"\u0000\u0154\u0158\u0005p\u0000\u0000\u0155\u0158\u0005q\u0000\u0000\u0156"+
		"\u0158\u0003\u00c4b\u0000\u0157\u0151\u0001\u0000\u0000\u0000\u0157\u0152"+
		"\u0001\u0000\u0000\u0000\u0157\u0153\u0001\u0000\u0000\u0000\u0157\u0154"+
		"\u0001\u0000\u0000\u0000\u0157\u0155\u0001\u0000\u0000\u0000\u0157\u0156"+
		"\u0001\u0000\u0000\u0000\u0158\u015b\u0001\u0000\u0000\u0000\u0159\u0157"+
		"\u0001\u0000\u0000\u0000\u0159\u015a\u0001\u0000\u0000\u0000\u015a\u015c"+
		"\u0001\u0000\u0000\u0000\u015b\u0159\u0001\u0000\u0000\u0000\u015c\u015f"+
		"\u0003\u00bc^\u0000\u015d\u015e\u0005\n\u0000\u0000\u015e\u0160\u0003"+
		"\u0080@\u0000\u015f\u015d\u0001\u0000\u0000\u0000\u015f\u0160\u0001\u0000"+
		"\u0000\u0000\u0160\u0161\u0001\u0000\u0000\u0000\u0161\u0162\u0005\u0002"+
		"\u0000\u0000\u0162\u001b\u0001\u0000\u0000\u0000\u0163\u0164\u0003D\""+
		"\u0000\u0164\u0165\u0005p\u0000\u0000\u0165\u0166\u0003\u00bc^\u0000\u0166"+
		"\u0167\u0005\n\u0000\u0000\u0167\u0168\u0003\u0080@\u0000\u0168\u0169"+
		"\u0005\u0002\u0000\u0000\u0169\u001d\u0001\u0000\u0000\u0000\u016a\u016b"+
		"\u0005\u0019\u0000\u0000\u016b\u016c\u0003\u00bc^\u0000\u016c\u016d\u0003"+
		"6\u001b\u0000\u016d\u016e\u0005\u0002\u0000\u0000\u016e\u001f\u0001\u0000"+
		"\u0000\u0000\u016f\u0170\u0005\u001a\u0000\u0000\u0170\u0171\u0003\u00bc"+
		"^\u0000\u0171\u0174\u0005\u001b\u0000\u0000\u0172\u0175\u0005\r\u0000"+
		"\u0000\u0173\u0175\u0003D\"\u0000\u0174\u0172\u0001\u0000\u0000\u0000"+
		"\u0174\u0173\u0001\u0000\u0000\u0000\u0175\u0176\u0001\u0000\u0000\u0000"+
		"\u0176\u0177\u0005\u0002\u0000\u0000\u0177!\u0001\u0000\u0000\u0000\u0178"+
		"\u0179\u0005\u001c\u0000\u0000\u0179\u017a\u0003\u00bc^\u0000\u017a\u0185"+
		"\u0005\u000f\u0000\u0000\u017b\u017c\u0003B!\u0000\u017c\u0182\u0005\u0002"+
		"\u0000\u0000\u017d\u017e\u0003B!\u0000\u017e\u017f\u0005\u0002\u0000\u0000"+
		"\u017f\u0181\u0001\u0000\u0000\u0000\u0180\u017d\u0001\u0000\u0000\u0000"+
		"\u0181\u0184\u0001\u0000\u0000\u0000\u0182\u0180\u0001\u0000\u0000\u0000"+
		"\u0182\u0183\u0001\u0000\u0000\u0000\u0183\u0186\u0001\u0000\u0000\u0000"+
		"\u0184\u0182\u0001\u0000\u0000\u0000\u0185\u017b\u0001\u0000\u0000\u0000"+
		"\u0185\u0186\u0001\u0000\u0000\u0000\u0186\u0187\u0001\u0000\u0000\u0000"+
		"\u0187\u0188\u0005\u0011\u0000\u0000\u0188#\u0001\u0000\u0000\u0000\u0189"+
		"\u018a\u0005\u001d\u0000\u0000\u018a\u018c\u0003\u00bc^\u0000\u018b\u018d"+
		"\u00036\u001b\u0000\u018c\u018b\u0001\u0000\u0000\u0000\u018c\u018d\u0001"+
		"\u0000\u0000\u0000\u018d\u0192\u0001\u0000\u0000\u0000\u018e\u0191\u0005"+
		"z\u0000\u0000\u018f\u0191\u0003\u00c4b\u0000\u0190\u018e\u0001\u0000\u0000"+
		"\u0000\u0190\u018f\u0001\u0000\u0000\u0000\u0191\u0194\u0001\u0000\u0000"+
		"\u0000\u0192\u0190\u0001\u0000\u0000\u0000\u0192\u0193\u0001\u0000\u0000"+
		"\u0000\u0193\u0197\u0001\u0000\u0000\u0000\u0194\u0192\u0001\u0000\u0000"+
		"\u0000\u0195\u0198\u0005\u0002\u0000\u0000\u0196\u0198\u0003R)\u0000\u0197"+
		"\u0195\u0001\u0000\u0000\u0000\u0197\u0196\u0001\u0000\u0000\u0000\u0198"+
		"%\u0001\u0000\u0000\u0000\u0199\u019f\u0003\u00bc^\u0000\u019a\u019c\u0005"+
		"\u0017\u0000\u0000\u019b\u019d\u0003\u0084B\u0000\u019c\u019b\u0001\u0000"+
		"\u0000\u0000\u019c\u019d\u0001\u0000\u0000\u0000\u019d\u019e\u0001\u0000"+
		"\u0000\u0000\u019e\u01a0\u0005\u0018\u0000\u0000\u019f\u019a\u0001\u0000"+
		"\u0000\u0000\u019f\u01a0\u0001\u0000\u0000\u0000\u01a0\'\u0001\u0000\u0000"+
		"\u0000\u01a1\u01a2\u0003*\u0015\u0000\u01a2\u01a3\u00036\u001b\u0000\u01a3"+
		"\u01a5\u0003.\u0017\u0000\u01a4\u01a6\u0003,\u0016\u0000\u01a5\u01a4\u0001"+
		"\u0000\u0000\u0000\u01a5\u01a6\u0001\u0000\u0000\u0000\u01a6\u01a9\u0001"+
		"\u0000\u0000\u0000\u01a7\u01aa\u0005\u0002\u0000\u0000\u01a8\u01aa\u0003"+
		"R)\u0000\u01a9\u01a7\u0001\u0000\u0000\u0000\u01a9\u01a8\u0001\u0000\u0000"+
		"\u0000\u01aa)\u0001\u0000\u0000\u0000\u01ab\u01ad\u0005\u001e\u0000\u0000"+
		"\u01ac\u01ae\u0003\u00bc^\u0000\u01ad\u01ac\u0001\u0000\u0000\u0000\u01ad"+
		"\u01ae\u0001\u0000\u0000\u0000\u01ae\u01b3\u0001\u0000\u0000\u0000\u01af"+
		"\u01b3\u0005~\u0000\u0000\u01b0\u01b3\u0005\u007f\u0000\u0000\u01b1\u01b3"+
		"\u0005\u0080\u0000\u0000\u01b2\u01ab\u0001\u0000\u0000\u0000\u01b2\u01af"+
		"\u0001\u0000\u0000\u0000\u01b2\u01b0\u0001\u0000\u0000\u0000\u01b2\u01b1"+
		"\u0001\u0000\u0000\u0000\u01b3+\u0001\u0000\u0000\u0000\u01b4\u01b5\u0005"+
		"\u001f\u0000\u0000\u01b5\u01b6\u00036\u001b\u0000\u01b6-\u0001\u0000\u0000"+
		"\u0000\u01b7\u01bd\u0003\u00c0`\u0000\u01b8\u01bd\u0005z\u0000\u0000\u01b9"+
		"\u01bd\u0003P(\u0000\u01ba\u01bd\u0003&\u0013\u0000\u01bb\u01bd\u0003"+
		"\u00c4b\u0000\u01bc\u01b7\u0001\u0000\u0000\u0000\u01bc\u01b8\u0001\u0000"+
		"\u0000\u0000\u01bc\u01b9\u0001\u0000\u0000\u0000\u01bc\u01ba\u0001\u0000"+
		"\u0000\u0000\u01bc\u01bb\u0001\u0000\u0000\u0000\u01bd\u01c0\u0001\u0000"+
		"\u0000\u0000\u01be\u01bc\u0001\u0000\u0000\u0000\u01be\u01bf\u0001\u0000"+
		"\u0000\u0000\u01bf/\u0001\u0000\u0000\u0000\u01c0\u01be\u0001\u0000\u0000"+
		"\u0000\u01c1\u01c2\u0005 \u0000\u0000\u01c2\u01c3\u0003\u00bc^\u0000\u01c3"+
		"\u01c5\u0003:\u001d\u0000\u01c4\u01c6\u0005n\u0000\u0000\u01c5\u01c4\u0001"+
		"\u0000\u0000\u0000\u01c5\u01c6\u0001\u0000\u0000\u0000\u01c6\u01c7\u0001"+
		"\u0000\u0000\u0000\u01c7\u01c8\u0005\u0002\u0000\u0000\u01c81\u0001\u0000"+
		"\u0000\u0000\u01c9\u01ca\u0003\u00bc^\u0000\u01ca3\u0001\u0000\u0000\u0000"+
		"\u01cb\u01cc\u0005!\u0000\u0000\u01cc\u01cd\u0003\u00bc^\u0000\u01cd\u01cf"+
		"\u0005\u000f\u0000\u0000\u01ce\u01d0\u00032\u0019\u0000\u01cf\u01ce\u0001"+
		"\u0000\u0000\u0000\u01cf\u01d0\u0001\u0000\u0000\u0000\u01d0\u01d5\u0001"+
		"\u0000\u0000\u0000\u01d1\u01d2\u0005\u0010\u0000\u0000\u01d2\u01d4\u0003"+
		"2\u0019\u0000\u01d3\u01d1\u0001\u0000\u0000\u0000\u01d4\u01d7\u0001\u0000"+
		"\u0000\u0000\u01d5\u01d3\u0001\u0000\u0000\u0000\u01d5\u01d6\u0001\u0000"+
		"\u0000\u0000\u01d6\u01d8\u0001\u0000\u0000\u0000\u01d7\u01d5\u0001\u0000"+
		"\u0000\u0000\u01d8\u01d9\u0005\u0011\u0000\u0000\u01d95\u0001\u0000\u0000"+
		"\u0000\u01da\u01e3\u0005\u0017\u0000\u0000\u01db\u01e0\u00038\u001c\u0000"+
		"\u01dc\u01dd\u0005\u0010\u0000\u0000\u01dd\u01df\u00038\u001c\u0000\u01de"+
		"\u01dc\u0001\u0000\u0000\u0000\u01df\u01e2\u0001\u0000\u0000\u0000\u01e0"+
		"\u01de\u0001\u0000\u0000\u0000\u01e0\u01e1\u0001\u0000\u0000\u0000\u01e1"+
		"\u01e4\u0001\u0000\u0000\u0000\u01e2\u01e0\u0001\u0000\u0000\u0000\u01e3"+
		"\u01db\u0001\u0000\u0000\u0000\u01e3\u01e4\u0001\u0000\u0000\u0000\u01e4"+
		"\u01e5\u0001\u0000\u0000\u0000\u01e5\u01e6\u0005\u0018\u0000\u0000\u01e6"+
		"7\u0001\u0000\u0000\u0000\u01e7\u01e9\u0003D\"\u0000\u01e8\u01ea\u0003"+
		"N\'\u0000\u01e9\u01e8\u0001\u0000\u0000\u0000\u01e9\u01ea\u0001\u0000"+
		"\u0000\u0000\u01ea\u01ec\u0001\u0000\u0000\u0000\u01eb\u01ed\u0003\u00bc"+
		"^\u0000\u01ec\u01eb\u0001\u0000\u0000\u0000\u01ec\u01ed\u0001\u0000\u0000"+
		"\u0000\u01ed9\u0001\u0000\u0000\u0000\u01ee\u01f7\u0005\u0017\u0000\u0000"+
		"\u01ef\u01f4\u0003<\u001e\u0000\u01f0\u01f1\u0005\u0010\u0000\u0000\u01f1"+
		"\u01f3\u0003<\u001e\u0000\u01f2\u01f0\u0001\u0000\u0000\u0000\u01f3\u01f6"+
		"\u0001\u0000\u0000\u0000\u01f4\u01f2\u0001\u0000\u0000\u0000\u01f4\u01f5"+
		"\u0001\u0000\u0000\u0000\u01f5\u01f8\u0001\u0000\u0000\u0000\u01f6\u01f4"+
		"\u0001\u0000\u0000\u0000\u01f7\u01ef\u0001\u0000\u0000\u0000\u01f7\u01f8"+
		"\u0001\u0000\u0000\u0000\u01f8\u01f9\u0001\u0000\u0000\u0000\u01f9\u01fa"+
		"\u0005\u0018\u0000\u0000\u01fa;\u0001\u0000\u0000\u0000\u01fb\u01fd\u0003"+
		"D\"\u0000\u01fc\u01fe\u0005u\u0000\u0000\u01fd\u01fc\u0001\u0000\u0000"+
		"\u0000\u01fd\u01fe\u0001\u0000\u0000\u0000\u01fe\u0200\u0001\u0000\u0000"+
		"\u0000\u01ff\u0201\u0003\u00bc^\u0000\u0200\u01ff\u0001\u0000\u0000\u0000"+
		"\u0200\u0201\u0001\u0000\u0000\u0000\u0201=\u0001\u0000\u0000\u0000\u0202"+
		"\u020b\u0005\u0017\u0000\u0000\u0203\u0208\u0003@ \u0000\u0204\u0205\u0005"+
		"\u0010\u0000\u0000\u0205\u0207\u0003@ \u0000\u0206\u0204\u0001\u0000\u0000"+
		"\u0000\u0207\u020a\u0001\u0000\u0000\u0000\u0208\u0206\u0001\u0000\u0000"+
		"\u0000\u0208\u0209\u0001\u0000\u0000\u0000\u0209\u020c\u0001\u0000\u0000"+
		"\u0000\u020a\u0208\u0001\u0000\u0000\u0000\u020b\u0203\u0001\u0000\u0000"+
		"\u0000\u020b\u020c\u0001\u0000\u0000\u0000\u020c\u020d\u0001\u0000\u0000"+
		"\u0000\u020d\u020e\u0005\u0018\u0000\u0000\u020e?\u0001\u0000\u0000\u0000"+
		"\u020f\u0211\u0003D\"\u0000\u0210\u0212\u0003N\'\u0000\u0211\u0210\u0001"+
		"\u0000\u0000\u0000\u0211\u0212\u0001\u0000\u0000\u0000\u0212A\u0001\u0000"+
		"\u0000\u0000\u0213\u0215\u0003D\"\u0000\u0214\u0216\u0003N\'\u0000\u0215"+
		"\u0214\u0001\u0000\u0000\u0000\u0215\u0216\u0001\u0000\u0000\u0000\u0216"+
		"\u0217\u0001\u0000\u0000\u0000\u0217\u0218\u0003\u00bc^\u0000\u0218C\u0001"+
		"\u0000\u0000\u0000\u0219\u021a\u0006\"\uffff\uffff\u0000\u021a\u0221\u0003"+
		"~?\u0000\u021b\u0221\u0003F#\u0000\u021c\u0221\u0003J%\u0000\u021d\u0221"+
		"\u0003L&\u0000\u021e\u021f\u0005$\u0000\u0000\u021f\u0221\u0005w\u0000"+
		"\u0000\u0220\u0219\u0001\u0000\u0000\u0000\u0220\u021b\u0001\u0000\u0000"+
		"\u0000\u0220\u021c\u0001\u0000\u0000\u0000\u0220\u021d\u0001\u0000\u0000"+
		"\u0000\u0220\u021e\u0001\u0000\u0000\u0000\u0221\u022a\u0001\u0000\u0000"+
		"\u0000\u0222\u0223\n\u0003\u0000\u0000\u0223\u0225\u0005\"\u0000\u0000"+
		"\u0224\u0226\u0003\u0080@\u0000\u0225\u0224\u0001\u0000\u0000\u0000\u0225"+
		"\u0226\u0001\u0000\u0000\u0000\u0226\u0227\u0001\u0000\u0000\u0000\u0227"+
		"\u0229\u0005#\u0000\u0000\u0228\u0222\u0001\u0000\u0000\u0000\u0229\u022c"+
		"\u0001\u0000\u0000\u0000\u022a\u0228\u0001\u0000\u0000\u0000\u022a\u022b"+
		"\u0001\u0000\u0000\u0000\u022bE\u0001\u0000\u0000\u0000\u022c\u022a\u0001"+
		"\u0000\u0000\u0000\u022d\u0232\u0003\u00bc^\u0000\u022e\u022f\u0005%\u0000"+
		"\u0000\u022f\u0231\u0003\u00bc^\u0000\u0230\u022e\u0001\u0000\u0000\u0000"+
		"\u0231\u0234\u0001\u0000\u0000\u0000\u0232\u0230\u0001\u0000\u0000\u0000"+
		"\u0232\u0233\u0001\u0000\u0000\u0000\u0233G\u0001\u0000\u0000\u0000\u0234"+
		"\u0232\u0001\u0000\u0000\u0000\u0235\u0238\u0003~?\u0000\u0236\u0238\u0003"+
		"F#\u0000\u0237\u0235\u0001\u0000\u0000\u0000\u0237\u0236\u0001\u0000\u0000"+
		"\u0000\u0238I\u0001\u0000\u0000\u0000\u0239\u023a\u0005&\u0000\u0000\u023a"+
		"\u023b\u0005\u0017\u0000\u0000\u023b\u023c\u0003H$\u0000\u023c\u023d\u0005"+
		"\'\u0000\u0000\u023d\u023e\u0003D\"\u0000\u023e\u023f\u0005\u0018\u0000"+
		"\u0000\u023fK\u0001\u0000\u0000\u0000\u0240\u0241\u0005\u001e\u0000\u0000"+
		"\u0241\u0247\u0003>\u001f\u0000\u0242\u0246\u0005v\u0000\u0000\u0243\u0246"+
		"\u0005t\u0000\u0000\u0244\u0246\u0003P(\u0000\u0245\u0242\u0001\u0000"+
		"\u0000\u0000\u0245\u0243\u0001\u0000\u0000\u0000\u0245\u0244\u0001\u0000"+
		"\u0000\u0000\u0246\u0249\u0001\u0000\u0000\u0000\u0247\u0245\u0001\u0000"+
		"\u0000\u0000\u0247\u0248\u0001\u0000\u0000\u0000\u0248\u024c\u0001\u0000"+
		"\u0000\u0000\u0249\u0247\u0001\u0000\u0000\u0000\u024a\u024b\u0005\u001f"+
		"\u0000\u0000\u024b\u024d\u0003>\u001f\u0000\u024c\u024a\u0001\u0000\u0000"+
		"\u0000\u024c\u024d\u0001\u0000\u0000\u0000\u024dM\u0001\u0000\u0000\u0000"+
		"\u024e\u024f\u0007\u0002\u0000\u0000\u024fO\u0001\u0000\u0000\u0000\u0250"+
		"\u0251\u0007\u0003\u0000\u0000\u0251Q\u0001\u0000\u0000\u0000\u0252\u0256"+
		"\u0005\u000f\u0000\u0000\u0253\u0255\u0003T*\u0000\u0254\u0253\u0001\u0000"+
		"\u0000\u0000\u0255\u0258\u0001\u0000\u0000\u0000\u0256\u0254\u0001\u0000"+
		"\u0000\u0000\u0256\u0257\u0001\u0000\u0000\u0000\u0257\u0259\u0001\u0000"+
		"\u0000\u0000\u0258\u0256\u0001\u0000\u0000\u0000\u0259\u025a\u0005\u0011"+
		"\u0000\u0000\u025aS\u0001\u0000\u0000\u0000\u025b\u026c\u0003X,\u0000"+
		"\u025c\u026c\u0003Z-\u0000\u025d\u026c\u0003^/\u0000\u025e\u026c\u0003"+
		"f3\u0000\u025f\u026c\u0003R)\u0000\u0260\u026c\u0003d2\u0000\u0261\u026c"+
		"\u0003h4\u0000\u0262\u026c\u0003j5\u0000\u0263\u026c\u0003l6\u0000\u0264"+
		"\u026c\u0003n7\u0000\u0265\u026c\u0003p8\u0000\u0266\u026c\u0003r9\u0000"+
		"\u0267\u026c\u0003t:\u0000\u0268\u026c\u0003`0\u0000\u0269\u026c\u0003"+
		"b1\u0000\u026a\u026c\u0003v;\u0000\u026b\u025b\u0001\u0000\u0000\u0000"+
		"\u026b\u025c\u0001\u0000\u0000\u0000\u026b\u025d\u0001\u0000\u0000\u0000"+
		"\u026b\u025e\u0001\u0000\u0000\u0000\u026b\u025f\u0001\u0000\u0000\u0000"+
		"\u026b\u0260\u0001\u0000\u0000\u0000\u026b\u0261\u0001\u0000\u0000\u0000"+
		"\u026b\u0262\u0001\u0000\u0000\u0000\u026b\u0263\u0001\u0000\u0000\u0000"+
		"\u026b\u0264\u0001\u0000\u0000\u0000\u026b\u0265\u0001\u0000\u0000\u0000"+
		"\u026b\u0266\u0001\u0000\u0000\u0000\u026b\u0267\u0001\u0000\u0000\u0000"+
		"\u026b\u0268\u0001\u0000\u0000\u0000\u026b\u0269\u0001\u0000\u0000\u0000"+
		"\u026b\u026a\u0001\u0000\u0000\u0000\u026cU\u0001\u0000\u0000\u0000\u026d"+
		"\u026e\u0003\u0080@\u0000\u026e\u026f\u0005\u0002\u0000\u0000\u026fW\u0001"+
		"\u0000\u0000\u0000\u0270\u0271\u0005+\u0000\u0000\u0271\u0272\u0005\u0017"+
		"\u0000\u0000\u0272\u0273\u0003\u0080@\u0000\u0273\u0274\u0005\u0018\u0000"+
		"\u0000\u0274\u0277\u0003T*\u0000\u0275\u0276\u0005,\u0000\u0000\u0276"+
		"\u0278\u0003T*\u0000\u0277\u0275\u0001\u0000\u0000\u0000\u0277\u0278\u0001"+
		"\u0000\u0000\u0000\u0278Y\u0001\u0000\u0000\u0000\u0279\u027a\u0005-\u0000"+
		"\u0000\u027a\u027c\u0003\u0080@\u0000\u027b\u027d\u0003,\u0016\u0000\u027c"+
		"\u027b\u0001\u0000\u0000\u0000\u027c\u027d\u0001\u0000\u0000\u0000\u027d"+
		"\u027e\u0001\u0000\u0000\u0000\u027e\u0280\u0003R)\u0000\u027f\u0281\u0003"+
		"\\.\u0000\u0280\u027f\u0001\u0000\u0000\u0000\u0281\u0282\u0001\u0000"+
		"\u0000\u0000\u0282\u0280\u0001\u0000\u0000\u0000\u0282\u0283\u0001\u0000"+
		"\u0000\u0000\u0283[\u0001\u0000\u0000\u0000\u0284\u0289\u0005.\u0000\u0000"+
		"\u0285\u0287\u0003\u00bc^\u0000\u0286\u0285\u0001\u0000\u0000\u0000\u0286"+
		"\u0287\u0001\u0000\u0000\u0000\u0287\u0288\u0001\u0000\u0000\u0000\u0288"+
		"\u028a\u00036\u001b\u0000\u0289\u0286\u0001\u0000\u0000\u0000\u0289\u028a"+
		"\u0001\u0000\u0000\u0000\u028a\u028b\u0001\u0000\u0000\u0000\u028b\u028c"+
		"\u0003R)\u0000\u028c]\u0001\u0000\u0000\u0000\u028d\u028e\u0005/\u0000"+
		"\u0000\u028e\u028f\u0005\u0017\u0000\u0000\u028f\u0290\u0003\u0080@\u0000"+
		"\u0290\u0291\u0005\u0018\u0000\u0000\u0291\u0292\u0003T*\u0000\u0292_"+
		"\u0001\u0000\u0000\u0000\u0293\u0296\u0003x<\u0000\u0294\u0296\u0003V"+
		"+\u0000\u0295\u0293\u0001\u0000\u0000\u0000\u0295\u0294\u0001\u0000\u0000"+
		"\u0000\u0296a\u0001\u0000\u0000\u0000\u0297\u0298\u00050\u0000\u0000\u0298"+
		"\u0299\u0003R)\u0000\u0299c\u0001\u0000\u0000\u0000\u029a\u029c\u0005"+
		"1\u0000\u0000\u029b\u029d\u0005\u0002\u0000\u0000\u029c\u029b\u0001\u0000"+
		"\u0000\u0000\u029c\u029d\u0001\u0000\u0000\u0000\u029de\u0001\u0000\u0000"+
		"\u0000\u029e\u029f\u0005\u001b\u0000\u0000\u029f\u02a2\u0005\u0017\u0000"+
		"\u0000\u02a0\u02a3\u0003`0\u0000\u02a1\u02a3\u0005\u0002\u0000\u0000\u02a2"+
		"\u02a0\u0001\u0000\u0000\u0000\u02a2\u02a1\u0001\u0000\u0000\u0000\u02a3"+
		"\u02a6\u0001\u0000\u0000\u0000\u02a4\u02a7\u0003V+\u0000\u02a5\u02a7\u0005"+
		"\u0002\u0000\u0000\u02a6\u02a4\u0001\u0000\u0000\u0000\u02a6\u02a5\u0001"+
		"\u0000\u0000\u0000\u02a7\u02a9\u0001\u0000\u0000\u0000\u02a8\u02aa\u0003"+
		"\u0080@\u0000\u02a9\u02a8\u0001\u0000\u0000\u0000\u02a9\u02aa\u0001\u0000"+
		"\u0000\u0000\u02aa\u02ab\u0001\u0000\u0000\u0000\u02ab\u02ac\u0005\u0018"+
		"\u0000\u0000\u02ac\u02ad\u0003T*\u0000\u02adg\u0001\u0000\u0000\u0000"+
		"\u02ae\u02b0\u00052\u0000\u0000\u02af\u02b1\u0005\u0082\u0000\u0000\u02b0"+
		"\u02af\u0001\u0000\u0000\u0000\u02b0\u02b1\u0001\u0000\u0000\u0000\u02b1"+
		"\u02b2\u0001\u0000\u0000\u0000\u02b2\u02b3\u0003\u0090H\u0000\u02b3i\u0001"+
		"\u0000\u0000\u0000\u02b4\u02b5\u00053\u0000\u0000\u02b5\u02b6\u0003T*"+
		"\u0000\u02b6\u02b7\u0005/\u0000\u0000\u02b7\u02b8\u0005\u0017\u0000\u0000"+
		"\u02b8\u02b9\u0003\u0080@\u0000\u02b9\u02ba\u0005\u0018\u0000\u0000\u02ba"+
		"\u02bb\u0005\u0002\u0000\u0000\u02bbk\u0001\u0000\u0000\u0000\u02bc\u02bd"+
		"\u0005r\u0000\u0000\u02bd\u02be\u0005\u0002\u0000\u0000\u02bem\u0001\u0000"+
		"\u0000\u0000\u02bf\u02c0\u0005o\u0000\u0000\u02c0\u02c1\u0005\u0002\u0000"+
		"\u0000\u02c1o\u0001\u0000\u0000\u0000\u02c2\u02c4\u00054\u0000\u0000\u02c3"+
		"\u02c5\u0003\u0080@\u0000\u02c4\u02c3\u0001\u0000\u0000\u0000\u02c4\u02c5"+
		"\u0001\u0000\u0000\u0000\u02c5\u02c6\u0001\u0000\u0000\u0000\u02c6\u02c7"+
		"\u0005\u0002\u0000\u0000\u02c7q\u0001\u0000\u0000\u0000\u02c8\u02c9\u0005"+
		"5\u0000\u0000\u02c9\u02ca\u0005\u0002\u0000\u0000\u02cas\u0001\u0000\u0000"+
		"\u0000\u02cb\u02cc\u00056\u0000\u0000\u02cc\u02cd\u0003\u008eG\u0000\u02cd"+
		"\u02ce\u0005\u0002\u0000\u0000\u02ceu\u0001\u0000\u0000\u0000\u02cf\u02d0"+
		"\u00057\u0000\u0000\u02d0\u02d1\u0003\u008eG\u0000\u02d1\u02d2\u0005\u0002"+
		"\u0000\u0000\u02d2w\u0001\u0000\u0000\u0000\u02d3\u02d4\u00058\u0000\u0000"+
		"\u02d4\u02db\u0003|>\u0000\u02d5\u02db\u0003B!\u0000\u02d6\u02d7\u0005"+
		"\u0017\u0000\u0000\u02d7\u02d8\u0003z=\u0000\u02d8\u02d9\u0005\u0018\u0000"+
		"\u0000\u02d9\u02db\u0001\u0000\u0000\u0000\u02da\u02d3\u0001\u0000\u0000"+
		"\u0000\u02da\u02d5\u0001\u0000\u0000\u0000\u02da\u02d6\u0001\u0000\u0000"+
		"\u0000\u02db\u02de\u0001\u0000\u0000\u0000\u02dc\u02dd\u0005\n\u0000\u0000"+
		"\u02dd\u02df\u0003\u0080@\u0000\u02de\u02dc\u0001\u0000\u0000\u0000\u02de"+
		"\u02df\u0001\u0000\u0000\u0000\u02df\u02e0\u0001\u0000\u0000\u0000\u02e0"+
		"\u02e1\u0005\u0002\u0000\u0000\u02e1y\u0001\u0000\u0000\u0000\u02e2\u02e4"+
		"\u0003B!\u0000\u02e3\u02e2\u0001\u0000\u0000\u0000\u02e3\u02e4\u0001\u0000"+
		"\u0000\u0000\u02e4\u02eb\u0001\u0000\u0000\u0000\u02e5\u02e7\u0005\u0010"+
		"\u0000\u0000\u02e6\u02e8\u0003B!\u0000\u02e7\u02e6\u0001\u0000\u0000\u0000"+
		"\u02e7\u02e8\u0001\u0000\u0000\u0000\u02e8\u02ea\u0001\u0000\u0000\u0000"+
		"\u02e9\u02e5\u0001\u0000\u0000\u0000\u02ea\u02ed\u0001\u0000\u0000\u0000"+
		"\u02eb\u02e9\u0001\u0000\u0000\u0000\u02eb\u02ec\u0001\u0000\u0000\u0000"+
		"\u02ec{\u0001\u0000\u0000\u0000\u02ed\u02eb\u0001\u0000\u0000\u0000\u02ee"+
		"\u02f5\u0005\u0017\u0000\u0000\u02ef\u02f1\u0003\u00bc^\u0000\u02f0\u02ef"+
		"\u0001\u0000\u0000\u0000\u02f0\u02f1\u0001\u0000\u0000\u0000\u02f1\u02f2"+
		"\u0001\u0000\u0000\u0000\u02f2\u02f4\u0005\u0010\u0000\u0000\u02f3\u02f0"+
		"\u0001\u0000\u0000\u0000\u02f4\u02f7\u0001\u0000\u0000\u0000\u02f5\u02f3"+
		"\u0001\u0000\u0000\u0000\u02f5\u02f6\u0001\u0000\u0000\u0000\u02f6\u02f9"+
		"\u0001\u0000\u0000\u0000\u02f7\u02f5\u0001\u0000\u0000\u0000\u02f8\u02fa"+
		"\u0003\u00bc^\u0000\u02f9\u02f8\u0001\u0000\u0000\u0000\u02f9\u02fa\u0001"+
		"\u0000\u0000\u0000\u02fa\u02fb\u0001\u0000\u0000\u0000\u02fb\u02fc\u0005"+
		"\u0018\u0000\u0000\u02fc}\u0001\u0000\u0000\u0000\u02fd\u02fe\u0007\u0004"+
		"\u0000\u0000\u02fe\u007f\u0001\u0000\u0000\u0000\u02ff\u0300\u0006@\uffff"+
		"\uffff\u0000\u0300\u0301\u0005>\u0000\u0000\u0301\u031c\u0003D\"\u0000"+
		"\u0302\u0303\u0005w\u0000\u0000\u0303\u0304\u0005\u0017\u0000\u0000\u0304"+
		"\u0305\u0003\u0080@\u0000\u0305\u0306\u0005\u0018\u0000\u0000\u0306\u031c"+
		"\u0001\u0000\u0000\u0000\u0307\u0308\u0003~?\u0000\u0308\u0309\u0005\u0017"+
		"\u0000\u0000\u0309\u030a\u0003\u0080@\u0000\u030a\u030b\u0005\u0018\u0000"+
		"\u0000\u030b\u031c\u0001\u0000\u0000\u0000\u030c\u030d\u0005\u0017\u0000"+
		"\u0000\u030d\u030e\u0003\u0080@\u0000\u030e\u030f\u0005\u0018\u0000\u0000"+
		"\u030f\u031c\u0001\u0000\u0000\u0000\u0310\u0311\u0007\u0005\u0000\u0000"+
		"\u0311\u031c\u0003\u0080@\u0013\u0312\u0313\u0007\u0006\u0000\u0000\u0313"+
		"\u031c\u0003\u0080@\u0012\u0314\u0315\u0007\u0007\u0000\u0000\u0315\u031c"+
		"\u0003\u0080@\u0011\u0316\u0317\u0005D\u0000\u0000\u0317\u031c\u0003\u0080"+
		"@\u0010\u0318\u0319\u0005\u0005\u0000\u0000\u0319\u031c\u0003\u0080@\u000f"+
		"\u031a\u031c\u0003\u0082A\u0000\u031b\u02ff\u0001\u0000\u0000\u0000\u031b"+
		"\u0302\u0001\u0000\u0000\u0000\u031b\u0307\u0001\u0000\u0000\u0000\u031b"+
		"\u030c\u0001\u0000\u0000\u0000\u031b\u0310\u0001\u0000\u0000\u0000\u031b"+
		"\u0312\u0001\u0000\u0000\u0000\u031b\u0314\u0001\u0000\u0000\u0000\u031b"+
		"\u0316\u0001\u0000\u0000\u0000\u031b\u0318\u0001\u0000\u0000\u0000\u031b"+
		"\u031a\u0001\u0000\u0000\u0000\u031c\u036b\u0001\u0000\u0000\u0000\u031d"+
		"\u031e\n\u000e\u0000\u0000\u031e\u031f\u0005E\u0000\u0000\u031f\u036a"+
		"\u0003\u0080@\u000f\u0320\u0321\n\r\u0000\u0000\u0321\u0322\u0007\b\u0000"+
		"\u0000\u0322\u036a\u0003\u0080@\u000e\u0323\u0324\n\f\u0000\u0000\u0324"+
		"\u0325\u0007\u0006\u0000\u0000\u0325\u036a\u0003\u0080@\r\u0326\u0327"+
		"\n\u000b\u0000\u0000\u0327\u0328\u0007\t\u0000\u0000\u0328\u036a\u0003"+
		"\u0080@\f\u0329\u032a\n\n\u0000\u0000\u032a\u032b\u0005J\u0000\u0000\u032b"+
		"\u036a\u0003\u0080@\u000b\u032c\u032d\n\t\u0000\u0000\u032d\u032e\u0005"+
		"\u0004\u0000\u0000\u032e\u036a\u0003\u0080@\n\u032f\u0330\n\b\u0000\u0000"+
		"\u0330\u0331\u0005K\u0000\u0000\u0331\u036a\u0003\u0080@\t\u0332\u0333"+
		"\n\u0007\u0000\u0000\u0333\u0334\u0007\n\u0000\u0000\u0334\u036a\u0003"+
		"\u0080@\b\u0335\u0336\n\u0006\u0000\u0000\u0336\u0337\u0007\u000b\u0000"+
		"\u0000\u0337\u036a\u0003\u0080@\u0007\u0338\u0339\n\u0005\u0000\u0000"+
		"\u0339\u033a\u0005N\u0000\u0000\u033a\u036a\u0003\u0080@\u0006\u033b\u033c"+
		"\n\u0004\u0000\u0000\u033c\u033d\u0005\u0003\u0000\u0000\u033d\u036a\u0003"+
		"\u0080@\u0005\u033e\u033f\n\u0003\u0000\u0000\u033f\u0340\u0005O\u0000"+
		"\u0000\u0340\u0341\u0003\u0080@\u0000\u0341\u0342\u0005?\u0000\u0000\u0342"+
		"\u0343\u0003\u0080@\u0004\u0343\u036a\u0001\u0000\u0000\u0000\u0344\u0345"+
		"\n\u0002\u0000\u0000\u0345\u0346\u0007\f\u0000\u0000\u0346\u036a\u0003"+
		"\u0080@\u0003\u0347\u0348\n\u001d\u0000\u0000\u0348\u036a\u0007\u0005"+
		"\u0000\u0000\u0349\u034a\n\u001b\u0000\u0000\u034a\u034c\u0005\"\u0000"+
		"\u0000\u034b\u034d\u0003\u0080@\u0000\u034c\u034b\u0001\u0000\u0000\u0000"+
		"\u034c\u034d\u0001\u0000\u0000\u0000\u034d\u034e\u0001\u0000\u0000\u0000"+
		"\u034e\u036a\u0005#\u0000\u0000\u034f\u0350\n\u001a\u0000\u0000\u0350"+
		"\u0352\u0005\"\u0000\u0000\u0351\u0353\u0003\u0080@\u0000\u0352\u0351"+
		"\u0001\u0000\u0000\u0000\u0352\u0353\u0001\u0000\u0000\u0000\u0353\u0354"+
		"\u0001\u0000\u0000\u0000\u0354\u0356\u0005?\u0000\u0000\u0355\u0357\u0003"+
		"\u0080@\u0000\u0356\u0355\u0001\u0000\u0000\u0000\u0356\u0357\u0001\u0000"+
		"\u0000\u0000\u0357\u0358\u0001\u0000\u0000\u0000\u0358\u036a\u0005#\u0000"+
		"\u0000\u0359\u035a\n\u0019\u0000\u0000\u035a\u035b\u0005%\u0000\u0000"+
		"\u035b\u036a\u0003\u00bc^\u0000\u035c\u035d\n\u0016\u0000\u0000\u035d"+
		"\u035e\u0005\u000f\u0000\u0000\u035e\u035f\u0003\u0086C\u0000\u035f\u0360"+
		"\u0005\u0011\u0000\u0000\u0360\u036a\u0001\u0000\u0000\u0000\u0361\u0363"+
		"\n\u0015\u0000\u0000\u0362\u0364\u0003\u008aE\u0000\u0363\u0362\u0001"+
		"\u0000\u0000\u0000\u0363\u0364\u0001\u0000\u0000\u0000\u0364\u0365\u0001"+
		"\u0000\u0000\u0000\u0365\u0366\u0005\u0017\u0000\u0000\u0366\u0367\u0003"+
		"\u008cF\u0000\u0367\u0368\u0005\u0018\u0000\u0000\u0368\u036a\u0001\u0000"+
		"\u0000\u0000\u0369\u031d\u0001\u0000\u0000\u0000\u0369\u0320\u0001\u0000"+
		"\u0000\u0000\u0369\u0323\u0001\u0000\u0000\u0000\u0369\u0326\u0001\u0000"+
		"\u0000\u0000\u0369\u0329\u0001\u0000\u0000\u0000\u0369\u032c\u0001\u0000"+
		"\u0000\u0000\u0369\u032f\u0001\u0000\u0000\u0000\u0369\u0332\u0001\u0000"+
		"\u0000\u0000\u0369\u0335\u0001\u0000\u0000\u0000\u0369\u0338\u0001\u0000"+
		"\u0000\u0000\u0369\u033b\u0001\u0000\u0000\u0000\u0369\u033e\u0001\u0000"+
		"\u0000\u0000\u0369\u0344\u0001\u0000\u0000\u0000\u0369\u0347\u0001\u0000"+
		"\u0000\u0000\u0369\u0349\u0001\u0000\u0000\u0000\u0369\u034f\u0001\u0000"+
		"\u0000\u0000\u0369\u0359\u0001\u0000\u0000\u0000\u0369\u035c\u0001\u0000"+
		"\u0000\u0000\u0369\u0361\u0001\u0000\u0000\u0000\u036a\u036d\u0001\u0000"+
		"\u0000\u0000\u036b\u0369\u0001\u0000\u0000\u0000\u036b\u036c\u0001\u0000"+
		"\u0000\u0000\u036c\u0081\u0001\u0000\u0000\u0000\u036d\u036b\u0001\u0000"+
		"\u0000\u0000\u036e\u0380\u0005|\u0000\u0000\u036f\u0380\u0005w\u0000\u0000"+
		"\u0370\u0380\u0005h\u0000\u0000\u0371\u0380\u0003\u00ba]\u0000\u0372\u0380"+
		"\u0003\u00be_\u0000\u0373\u0380\u0003\u00b6[\u0000\u0374\u0377\u0003\u00b8"+
		"\\\u0000\u0375\u0376\u0005\"\u0000\u0000\u0376\u0378\u0005#\u0000\u0000"+
		"\u0377\u0375\u0001\u0000\u0000\u0000\u0377\u0378\u0001\u0000\u0000\u0000"+
		"\u0378\u0380\u0001\u0000\u0000\u0000\u0379\u037c\u0003\u00bc^\u0000\u037a"+
		"\u037b\u0005\"\u0000\u0000\u037b\u037d\u0005#\u0000\u0000\u037c\u037a"+
		"\u0001\u0000\u0000\u0000\u037c\u037d\u0001\u0000\u0000\u0000\u037d\u0380"+
		"\u0001\u0000\u0000\u0000\u037e\u0380\u0003\u00c6c\u0000\u037f\u036e\u0001"+
		"\u0000\u0000\u0000\u037f\u036f\u0001\u0000\u0000\u0000\u037f\u0370\u0001"+
		"\u0000\u0000\u0000\u037f\u0371\u0001\u0000\u0000\u0000\u037f\u0372\u0001"+
		"\u0000\u0000\u0000\u037f\u0373\u0001\u0000\u0000\u0000\u037f\u0374\u0001"+
		"\u0000\u0000\u0000\u037f\u0379\u0001\u0000\u0000\u0000\u037f\u037e\u0001"+
		"\u0000\u0000\u0000\u0380\u0083\u0001\u0000\u0000\u0000\u0381\u0386\u0003"+
		"\u0080@\u0000\u0382\u0383\u0005\u0010\u0000\u0000\u0383\u0385\u0003\u0080"+
		"@\u0000\u0384\u0382\u0001\u0000\u0000\u0000\u0385\u0388\u0001\u0000\u0000"+
		"\u0000\u0386\u0384\u0001\u0000\u0000\u0000\u0386\u0387\u0001\u0000\u0000"+
		"\u0000\u0387\u0085\u0001\u0000\u0000\u0000\u0388\u0386\u0001\u0000\u0000"+
		"\u0000\u0389\u038e\u0003\u0088D\u0000\u038a\u038b\u0005\u0010\u0000\u0000"+
		"\u038b\u038d\u0003\u0088D\u0000\u038c\u038a\u0001\u0000\u0000\u0000\u038d"+
		"\u0390\u0001\u0000\u0000\u0000\u038e\u038c\u0001\u0000\u0000\u0000\u038e"+
		"\u038f\u0001\u0000\u0000\u0000\u038f\u0392\u0001\u0000\u0000\u0000\u0390"+
		"\u038e\u0001\u0000\u0000\u0000\u0391\u0393\u0005\u0010\u0000\u0000\u0392"+
		"\u0391\u0001\u0000\u0000\u0000\u0392\u0393\u0001\u0000\u0000\u0000\u0393"+
		"\u0087\u0001\u0000\u0000\u0000\u0394\u0395\u0003\u00bc^\u0000\u0395\u0396"+
		"\u0005?\u0000\u0000\u0396\u0397\u0003\u0080@\u0000\u0397\u0089\u0001\u0000"+
		"\u0000\u0000\u0398\u039a\u0005\u000f\u0000\u0000\u0399\u039b\u0003\u0086"+
		"C\u0000\u039a\u0399\u0001\u0000\u0000\u0000\u039a\u039b\u0001\u0000\u0000"+
		"\u0000\u039b\u039c\u0001\u0000\u0000\u0000\u039c\u039d\u0005\u0011\u0000"+
		"\u0000\u039d\u008b\u0001\u0000\u0000\u0000\u039e\u03a0\u0005\u000f\u0000"+
		"\u0000\u039f\u03a1\u0003\u0086C\u0000\u03a0\u039f\u0001\u0000\u0000\u0000"+
		"\u03a0\u03a1\u0001\u0000\u0000\u0000\u03a1\u03a2\u0001\u0000\u0000\u0000"+
		"\u03a2\u03a7\u0005\u0011\u0000\u0000\u03a3\u03a5\u0003\u0084B\u0000\u03a4"+
		"\u03a3\u0001\u0000\u0000\u0000\u03a4\u03a5\u0001\u0000\u0000\u0000\u03a5"+
		"\u03a7\u0001\u0000\u0000\u0000\u03a6\u039e\u0001\u0000\u0000\u0000\u03a6"+
		"\u03a4\u0001\u0000\u0000\u0000\u03a7\u008d\u0001\u0000\u0000\u0000\u03a8"+
		"\u03a9\u0003\u0080@\u0000\u03a9\u03aa\u0005\u0017\u0000\u0000\u03aa\u03ab"+
		"\u0003\u008cF\u0000\u03ab\u03ac\u0005\u0018\u0000\u0000\u03ac\u008f\u0001"+
		"\u0000\u0000\u0000\u03ad\u03b1\u0005\u000f\u0000\u0000\u03ae\u03b0\u0003"+
		"\u0092I\u0000\u03af\u03ae\u0001\u0000\u0000\u0000\u03b0\u03b3\u0001\u0000"+
		"\u0000\u0000\u03b1\u03af\u0001\u0000\u0000\u0000\u03b1\u03b2\u0001\u0000"+
		"\u0000\u0000\u03b2\u03b4\u0001\u0000\u0000\u0000\u03b3\u03b1\u0001\u0000"+
		"\u0000\u0000\u03b4\u03b5\u0005\u0011\u0000\u0000\u03b5\u0091\u0001\u0000"+
		"\u0000\u0000\u03b6\u03c9\u0003\u00bc^\u0000\u03b7\u03c9\u0003\u0090H\u0000"+
		"\u03b8\u03c9\u0003\u0094J\u0000\u03b9\u03c9\u0003\u009aM\u0000\u03ba\u03c9"+
		"\u0003\u009cN\u0000\u03bb\u03c9\u0003\u00a2Q\u0000\u03bc\u03c9\u0003\u00a4"+
		"R\u0000\u03bd\u03c9\u0003\u00a6S\u0000\u03be\u03c9\u0003\u00aaU\u0000"+
		"\u03bf\u03c9\u0003\u00aeW\u0000\u03c0\u03c9\u0003\u00b0X\u0000\u03c1\u03c9"+
		"\u0005o\u0000\u0000\u03c2\u03c9\u0005r\u0000\u0000\u03c3\u03c9\u0005s"+
		"\u0000\u0000\u03c4\u03c9\u0003\u00b4Z\u0000\u03c5\u03c9\u0003\u00ba]\u0000"+
		"\u03c6\u03c9\u0003\u00c6c\u0000\u03c7\u03c9\u0003\u00be_\u0000\u03c8\u03b6"+
		"\u0001\u0000\u0000\u0000\u03c8\u03b7\u0001\u0000\u0000\u0000\u03c8\u03b8"+
		"\u0001\u0000\u0000\u0000\u03c8\u03b9\u0001\u0000\u0000\u0000\u03c8\u03ba"+
		"\u0001\u0000\u0000\u0000\u03c8\u03bb\u0001\u0000\u0000\u0000\u03c8\u03bc"+
		"\u0001\u0000\u0000\u0000\u03c8\u03bd\u0001\u0000\u0000\u0000\u03c8\u03be"+
		"\u0001\u0000\u0000\u0000\u03c8\u03bf\u0001\u0000\u0000\u0000\u03c8\u03c0"+
		"\u0001\u0000\u0000\u0000\u03c8\u03c1\u0001\u0000\u0000\u0000\u03c8\u03c2"+
		"\u0001\u0000\u0000\u0000\u03c8\u03c3\u0001\u0000\u0000\u0000\u03c8\u03c4"+
		"\u0001\u0000\u0000\u0000\u03c8\u03c5\u0001\u0000\u0000\u0000\u03c8\u03c6"+
		"\u0001\u0000\u0000\u0000\u03c8\u03c7\u0001\u0000\u0000\u0000\u03c9\u0093"+
		"\u0001\u0000\u0000\u0000\u03ca\u03ce\u0003\u0098L\u0000\u03cb\u03ce\u0003"+
		"\u00b2Y\u0000\u03cc\u03ce\u0003\u0096K\u0000\u03cd\u03ca\u0001\u0000\u0000"+
		"\u0000\u03cd\u03cb\u0001\u0000\u0000\u0000\u03cd\u03cc\u0001\u0000\u0000"+
		"\u0000\u03ce\u0095\u0001\u0000\u0000\u0000\u03cf\u03d0\u0003\u00bc^\u0000"+
		"\u03d0\u03d1\u0005%\u0000\u0000\u03d1\u03d2\u0003\u00bc^\u0000\u03d2\u0097"+
		"\u0001\u0000\u0000\u0000\u03d3\u03d8\u00054\u0000\u0000\u03d4\u03d8\u0005"+
		"$\u0000\u0000\u03d5\u03d8\u0005;\u0000\u0000\u03d6\u03d8\u0003\u00bc^"+
		"\u0000\u03d7\u03d3\u0001\u0000\u0000\u0000\u03d7\u03d4\u0001\u0000\u0000"+
		"\u0000\u03d7\u03d5\u0001\u0000\u0000\u0000\u03d7\u03d6\u0001\u0000\u0000"+
		"\u0000\u03d8\u03e5\u0001\u0000\u0000\u0000\u03d9\u03db\u0005\u0017\u0000"+
		"\u0000\u03da\u03dc\u0003\u0094J\u0000\u03db\u03da\u0001\u0000\u0000\u0000"+
		"\u03db\u03dc\u0001\u0000\u0000\u0000\u03dc\u03e1\u0001\u0000\u0000\u0000"+
		"\u03dd\u03de\u0005\u0010\u0000\u0000\u03de\u03e0\u0003\u0094J\u0000\u03df"+
		"\u03dd\u0001\u0000\u0000\u0000\u03e0\u03e3\u0001\u0000\u0000\u0000\u03e1"+
		"\u03df\u0001\u0000\u0000\u0000\u03e1\u03e2\u0001\u0000\u0000\u0000\u03e2"+
		"\u03e4\u0001\u0000\u0000\u0000\u03e3\u03e1\u0001\u0000\u0000\u0000\u03e4"+
		"\u03e6\u0005\u0018\u0000\u0000\u03e5\u03d9\u0001\u0000\u0000\u0000\u03e5"+
		"\u03e6\u0001\u0000\u0000\u0000\u03e6\u0099\u0001\u0000\u0000\u0000\u03e7"+
		"\u03e8\u0005Z\u0000\u0000\u03e8\u03eb\u0003\u009eO\u0000\u03e9\u03ea\u0005"+
		"[\u0000\u0000\u03ea\u03ec\u0003\u0094J\u0000\u03eb\u03e9\u0001\u0000\u0000"+
		"\u0000\u03eb\u03ec\u0001\u0000\u0000\u0000\u03ec\u009b\u0001\u0000\u0000"+
		"\u0000\u03ed\u03ee\u0003\u009eO\u0000\u03ee\u03ef\u0005[\u0000\u0000\u03ef"+
		"\u03f0\u0003\u0094J\u0000\u03f0\u009d\u0001\u0000\u0000\u0000\u03f1\u03f8"+
		"\u0003\u00bc^\u0000\u03f2\u03f8\u0003\u0096K\u0000\u03f3\u03f4\u0005\u0017"+
		"\u0000\u0000\u03f4\u03f5\u0003\u00a0P\u0000\u03f5\u03f6\u0005\u0018\u0000"+
		"\u0000\u03f6\u03f8\u0001\u0000\u0000\u0000\u03f7\u03f1\u0001\u0000\u0000"+
		"\u0000\u03f7\u03f2\u0001\u0000\u0000\u0000\u03f7\u03f3\u0001\u0000\u0000"+
		"\u0000\u03f8\u009f\u0001\u0000\u0000\u0000\u03f9\u03fe\u0003\u00bc^\u0000"+
		"\u03fa\u03fb\u0005\u0010\u0000\u0000\u03fb\u03fd\u0003\u00bc^\u0000\u03fc"+
		"\u03fa\u0001\u0000\u0000\u0000\u03fd\u0400\u0001\u0000\u0000\u0000\u03fe"+
		"\u03fc\u0001\u0000\u0000\u0000\u03fe\u03ff\u0001\u0000\u0000\u0000\u03ff"+
		"\u00a1\u0001\u0000\u0000\u0000\u0400\u03fe\u0001\u0000\u0000\u0000\u0401"+
		"\u0402\u0005\\\u0000\u0000\u0402\u0403\u0003\u00bc^\u0000\u0403\u00a3"+
		"\u0001\u0000\u0000\u0000\u0404\u0405\u0003\u00bc^\u0000\u0405\u0406\u0005"+
		"?\u0000\u0000\u0406\u00a5\u0001\u0000\u0000\u0000\u0407\u0408\u0005]\u0000"+
		"\u0000\u0408\u040c\u0003\u0094J\u0000\u0409\u040b\u0003\u00a8T\u0000\u040a"+
		"\u0409\u0001\u0000\u0000\u0000\u040b\u040e\u0001\u0000\u0000\u0000\u040c"+
		"\u040a\u0001\u0000\u0000\u0000\u040c\u040d\u0001\u0000\u0000\u0000\u040d"+
		"\u00a7\u0001\u0000\u0000\u0000\u040e\u040c\u0001\u0000\u0000\u0000\u040f"+
		"\u0410\u0005^\u0000\u0000\u0410\u0411\u0003\u00b2Y\u0000\u0411\u0412\u0003"+
		"\u0090H\u0000\u0412\u0416\u0001\u0000\u0000\u0000\u0413\u0414\u0005_\u0000"+
		"\u0000\u0414\u0416\u0003\u0090H\u0000\u0415\u040f\u0001\u0000\u0000\u0000"+
		"\u0415\u0413\u0001\u0000\u0000\u0000\u0416\u00a9\u0001\u0000\u0000\u0000"+
		"\u0417\u0418\u0005\u001e\u0000\u0000\u0418\u0419\u0003\u00bc^\u0000\u0419"+
		"\u041b\u0005\u0017\u0000\u0000\u041a\u041c\u0003\u00a0P\u0000\u041b\u041a"+
		"\u0001\u0000\u0000\u0000\u041b\u041c\u0001\u0000\u0000\u0000\u041c\u041d"+
		"\u0001\u0000\u0000\u0000\u041d\u041f\u0005\u0018\u0000\u0000\u041e\u0420"+
		"\u0003\u00acV\u0000\u041f\u041e\u0001\u0000\u0000\u0000\u041f\u0420\u0001"+
		"\u0000\u0000\u0000\u0420\u0421\u0001\u0000\u0000\u0000\u0421\u0422\u0003"+
		"\u0090H\u0000\u0422\u00ab\u0001\u0000\u0000\u0000\u0423\u0424\u0005`\u0000"+
		"\u0000\u0424\u0425\u0003\u00a0P\u0000\u0425\u00ad\u0001\u0000\u0000\u0000"+
		"\u0426\u0429\u0005\u001b\u0000\u0000\u0427\u042a\u0003\u0090H\u0000\u0428"+
		"\u042a\u0003\u0094J\u0000\u0429\u0427\u0001\u0000\u0000\u0000\u0429\u0428"+
		"\u0001\u0000\u0000\u0000\u042a\u042b\u0001\u0000\u0000\u0000\u042b\u042e"+
		"\u0003\u0094J\u0000\u042c\u042f\u0003\u0090H\u0000\u042d\u042f\u0003\u0094"+
		"J\u0000\u042e\u042c\u0001\u0000\u0000\u0000\u042e\u042d\u0001\u0000\u0000"+
		"\u0000\u042f\u0430\u0001\u0000\u0000\u0000\u0430\u0431\u0003\u0090H\u0000"+
		"\u0431\u00af\u0001\u0000\u0000\u0000\u0432\u0433\u0005+\u0000\u0000\u0433"+
		"\u0434\u0003\u0094J\u0000\u0434\u0435\u0003\u0090H\u0000\u0435\u00b1\u0001"+
		"\u0000\u0000\u0000\u0436\u043b\u0003\u00c6c\u0000\u0437\u043b\u0005i\u0000"+
		"\u0000\u0438\u043b\u0005j\u0000\u0000\u0439\u043b\u0003\u00be_\u0000\u043a"+
		"\u0436\u0001\u0000\u0000\u0000\u043a\u0437\u0001\u0000\u0000\u0000\u043a"+
		"\u0438\u0001\u0000\u0000\u0000\u043a\u0439\u0001\u0000\u0000\u0000\u043b"+
		"\u00b3\u0001\u0000\u0000\u0000\u043c\u043d\u00052\u0000\u0000\u043d\u043e"+
		"\u0003\u00bc^\u0000\u043e\u043f\u0003\u0090H\u0000\u043f\u00b5\u0001\u0000"+
		"\u0000\u0000\u0440\u044d\u0005\u0017\u0000\u0000\u0441\u0443\u0003\u0080"+
		"@\u0000\u0442\u0441\u0001\u0000\u0000\u0000\u0442\u0443\u0001\u0000\u0000"+
		"\u0000\u0443\u044a\u0001\u0000\u0000\u0000\u0444\u0446\u0005\u0010\u0000"+
		"\u0000\u0445\u0447\u0003\u0080@\u0000\u0446\u0445\u0001\u0000\u0000\u0000"+
		"\u0446\u0447\u0001\u0000\u0000\u0000\u0447\u0449\u0001\u0000\u0000\u0000"+
		"\u0448\u0444\u0001\u0000\u0000\u0000\u0449\u044c\u0001\u0000\u0000\u0000"+
		"\u044a\u0448\u0001\u0000\u0000\u0000\u044a\u044b\u0001\u0000\u0000\u0000"+
		"\u044b\u044e\u0001\u0000\u0000\u0000\u044c\u044a\u0001\u0000\u0000\u0000"+
		"\u044d\u0442\u0001\u0000\u0000\u0000\u044d\u044e\u0001\u0000\u0000\u0000"+
		"\u044e\u044f\u0001\u0000\u0000\u0000\u044f\u045d\u0005\u0018\u0000\u0000"+
		"\u0450\u0459\u0005\"\u0000\u0000\u0451\u0456\u0003\u0080@\u0000\u0452"+
		"\u0453\u0005\u0010\u0000\u0000\u0453\u0455\u0003\u0080@\u0000\u0454\u0452"+
		"\u0001\u0000\u0000\u0000\u0455\u0458\u0001\u0000\u0000\u0000\u0456\u0454"+
		"\u0001\u0000\u0000\u0000\u0456\u0457\u0001\u0000\u0000\u0000\u0457\u045a"+
		"\u0001\u0000\u0000\u0000\u0458\u0456\u0001\u0000\u0000\u0000\u0459\u0451"+
		"\u0001\u0000\u0000\u0000\u0459\u045a\u0001\u0000\u0000\u0000\u045a\u045b"+
		"\u0001\u0000\u0000\u0000\u045b\u045d\u0005#\u0000\u0000\u045c\u0440\u0001"+
		"\u0000\u0000\u0000\u045c\u0450\u0001\u0000\u0000\u0000\u045d\u00b7\u0001"+
		"\u0000\u0000\u0000\u045e\u0461\u0003~?\u0000\u045f\u0461\u0003F#\u0000"+
		"\u0460\u045e\u0001\u0000\u0000\u0000\u0460\u045f\u0001\u0000\u0000\u0000"+
		"\u0461\u00b9\u0001\u0000\u0000\u0000\u0462\u0464\u0007\r\u0000\u0000\u0463"+
		"\u0465\u0005k\u0000\u0000\u0464\u0463\u0001\u0000\u0000\u0000\u0464\u0465"+
		"\u0001\u0000\u0000\u0000\u0465\u00bb\u0001\u0000\u0000\u0000\u0466\u046f"+
		"\u0003\u00c2a\u0000\u0467\u046f\u0005\u000e\u0000\u0000\u0468\u046f\u0005"+
		"*\u0000\u0000\u0469\u046f\u0005\u0080\u0000\u0000\u046a\u046f\u0005a\u0000"+
		"\u0000\u046b\u046f\u00057\u0000\u0000\u046c\u046f\u0005\u0019\u0000\u0000"+
		"\u046d\u046f\u0005\u0081\u0000\u0000\u046e\u0466\u0001\u0000\u0000\u0000"+
		"\u046e\u0467\u0001\u0000\u0000\u0000\u046e\u0468\u0001\u0000\u0000\u0000"+
		"\u046e\u0469\u0001\u0000\u0000\u0000\u046e\u046a\u0001\u0000\u0000\u0000"+
		"\u046e\u046b\u0001\u0000\u0000\u0000\u046e\u046c\u0001\u0000\u0000\u0000"+
		"\u046e\u046d\u0001\u0000\u0000\u0000\u046f\u00bd\u0001\u0000\u0000\u0000"+
		"\u0470\u0472\u0005l\u0000\u0000\u0471\u0470\u0001\u0000\u0000\u0000\u0472"+
		"\u0473\u0001\u0000\u0000\u0000\u0473\u0471\u0001\u0000\u0000\u0000\u0473"+
		"\u0474\u0001\u0000\u0000\u0000\u0474\u00bf\u0001\u0000\u0000\u0000\u0475"+
		"\u0476\u0007\u000e\u0000\u0000\u0476\u00c1\u0001\u0000\u0000\u0000\u0477"+
		"\u0488\u0005n\u0000\u0000\u0478\u0488\u0005o\u0000\u0000\u0479\u0488\u0005"+
		"p\u0000\u0000\u047a\u0488\u0005q\u0000\u0000\u047b\u0488\u0005r\u0000"+
		"\u0000\u047c\u0488\u0005s\u0000\u0000\u047d\u0488\u0005u\u0000\u0000\u047e"+
		"\u0488\u0003\u00c0`\u0000\u047f\u0488\u0005w\u0000\u0000\u0480\u0488\u0005"+
		"z\u0000\u0000\u0481\u0488\u0005{\u0000\u0000\u0482\u0488\u0005|\u0000"+
		"\u0000\u0483\u0488\u0005}\u0000\u0000\u0484\u0488\u0005~\u0000\u0000\u0485"+
		"\u0488\u0005\u007f\u0000\u0000\u0486\u0488\u0005\u0080\u0000\u0000\u0487"+
		"\u0477\u0001\u0000\u0000\u0000\u0487\u0478\u0001\u0000\u0000\u0000\u0487"+
		"\u0479\u0001\u0000\u0000\u0000\u0487\u047a\u0001\u0000\u0000\u0000\u0487"+
		"\u047b\u0001\u0000\u0000\u0000\u0487\u047c\u0001\u0000\u0000\u0000\u0487"+
		"\u047d\u0001\u0000\u0000\u0000\u0487\u047e\u0001\u0000\u0000\u0000\u0487"+
		"\u047f\u0001\u0000\u0000\u0000\u0487\u0480\u0001\u0000\u0000\u0000\u0487"+
		"\u0481\u0001\u0000\u0000\u0000\u0487\u0482\u0001\u0000\u0000\u0000\u0487"+
		"\u0483\u0001\u0000\u0000\u0000\u0487\u0484\u0001\u0000\u0000\u0000\u0487"+
		"\u0485\u0001\u0000\u0000\u0000\u0487\u0486\u0001\u0000\u0000\u0000\u0488"+
		"\u00c3\u0001\u0000\u0000\u0000\u0489\u0495\u0005b\u0000\u0000\u048a\u048b"+
		"\u0005\u0017\u0000\u0000\u048b\u0490\u0003F#\u0000\u048c\u048d\u0005\u0010"+
		"\u0000\u0000\u048d\u048f\u0003F#\u0000\u048e\u048c\u0001\u0000\u0000\u0000"+
		"\u048f\u0492\u0001\u0000\u0000\u0000\u0490\u048e\u0001\u0000\u0000\u0000"+
		"\u0490\u0491\u0001\u0000\u0000\u0000\u0491\u0493\u0001\u0000\u0000\u0000"+
		"\u0492\u0490\u0001\u0000\u0000\u0000\u0493\u0494\u0005\u0018\u0000\u0000"+
		"\u0494\u0496\u0001\u0000\u0000\u0000\u0495\u048a\u0001\u0000\u0000\u0000"+
		"\u0495\u0496\u0001\u0000\u0000\u0000\u0496\u00c5\u0001\u0000\u0000\u0000"+
		"\u0497\u0499\u0005\u0082\u0000\u0000\u0498\u0497\u0001\u0000\u0000\u0000"+
		"\u0499\u049a\u0001\u0000\u0000\u0000\u049a\u0498\u0001\u0000\u0000\u0000"+
		"\u049a\u049b\u0001\u0000\u0000\u0000\u049b\u00c7\u0001\u0000\u0000\u0000"+
		"\u0085\u00d0\u00d2\u00e0\u00e4\u00e9\u00ef\u00f3\u00f6\u00fb\u0101\u0108"+
		"\u010c\u0119\u0121\u0126\u0130\u0133\u0139\u0141\u0144\u014e\u0157\u0159"+
		"\u015f\u0174\u0182\u0185\u018c\u0190\u0192\u0197\u019c\u019f\u01a5\u01a9"+
		"\u01ad\u01b2\u01bc\u01be\u01c5\u01cf\u01d5\u01e0\u01e3\u01e9\u01ec\u01f4"+
		"\u01f7\u01fd\u0200\u0208\u020b\u0211\u0215\u0220\u0225\u022a\u0232\u0237"+
		"\u0245\u0247\u024c\u0256\u026b\u0277\u027c\u0282\u0286\u0289\u0295\u029c"+
		"\u02a2\u02a6\u02a9\u02b0\u02c4\u02da\u02de\u02e3\u02e7\u02eb\u02f0\u02f5"+
		"\u02f9\u031b\u034c\u0352\u0356\u0363\u0369\u036b\u0377\u037c\u037f\u0386"+
		"\u038e\u0392\u039a\u03a0\u03a4\u03a6\u03b1\u03c8\u03cd\u03d7\u03db\u03e1"+
		"\u03e5\u03eb\u03f7\u03fe\u040c\u0415\u041b\u041f\u0429\u042e\u043a\u0442"+
		"\u0446\u044a\u044d\u0456\u0459\u045c\u0460\u0464\u046e\u0473\u0487\u0490"+
		"\u0495\u049a";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}