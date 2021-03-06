/*
 * 05/13/2014
 *
 * GLSLTokenMaker.java - An object that can take a chunk of text and
 * return a linked list of tokens representing it in the GLSL programming
 * language.
 * 
 * This library is distributed under a modified BSD license.  See the included
 * RSyntaxTextArea.License.txt file for details.
 */
package infinity.resource.text.modes;

import java.io.IOException;

import javax.swing.text.Segment;

import org.fife.ui.rsyntaxtextarea.AbstractJFlexCTokenMaker;
import org.fife.ui.rsyntaxtextarea.Token;
import org.fife.ui.rsyntaxtextarea.TokenImpl;


/**
 * Scanner for the GLSL programming language (based on scanner for C).
 *
 * This implementation was created using
 * <a href="http://www.jflex.de/">JFlex</a> 1.5.1; however, the generated file
 * was modified for performance.  Memory allocation needs to be almost
 * completely removed to be competitive with the handwritten lexers (subclasses
 * of <code>AbstractTokenMaker</code>, so this class has been modified so that
 * Strings are never allocated (via yytext()), and the scanner never has to
 * worry about refilling its buffer (needlessly copying chars around).
 * We can achieve this because RText always scans exactly 1 line of tokens at a
 * time, and hands the scanner this line as an array of characters (a Segment
 * really).  Since tokens contain pointers to char arrays instead of Strings
 * holding their contents, there is no need for allocating new memory for
 * Strings.<p>
 *
 * The actual algorithm generated for scanning has, of course, not been
 * modified.<p>
 *
 * If you wish to regenerate this file yourself, keep in mind the following:
 * <ul>
 *   <li>The generated <code>GLSLTokenMaker.java</code> file will contain two
 *       definitions of both <code>zzRefill</code> and <code>yyreset</code>.
 *       You should hand-delete the second of each definition (the ones
 *       generated by the lexer), as these generated methods modify the input
 *       buffer, which we'll never have to do.</li>
 *   <li>You should also change the declaration/definition of zzBuffer to NOT
 *       be initialized.  This is a needless memory allocation for us since we
 *       will be pointing the array somewhere else anyway.</li>
 *   <li>You should NOT call <code>yylex()</code> on the generated scanner
 *       directly; rather, you should use <code>getTokenList</code> as you would
 *       with any other <code>TokenMaker</code> instance.</li>
 * </ul>
 *
 * @author Robert Futrell, argent77
 * @version 0.1
 *
 */
%%

%public
%class GLSLTokenMaker
%extends AbstractJFlexCTokenMaker
%unicode
%type org.fife.ui.rsyntaxtextarea.Token


%{


  /**
   * Constructor.  This must be here because JFlex does not generate a
   * no-parameter constructor.
   */
  public GLSLTokenMaker() {
    super();
  }


  /**
   * Adds the token specified to the current linked list of tokens.
   *
   * @param tokenType The token's type.
   * @see #addToken(int, int, int)
   */
  private void addHyperlinkToken(int start, int end, int tokenType) {
    int so = start + offsetShift;
    addToken(zzBuffer, start,end, tokenType, so, true);
  }


  /**
   * Adds the token specified to the current linked list of tokens.
   *
   * @param tokenType The token's type.
   */
  private void addToken(int tokenType) {
    addToken(zzStartRead, zzMarkedPos-1, tokenType);
  }


  /**
   * Adds the token specified to the current linked list of tokens.
   *
   * @param tokenType The token's type.
   */
  private void addToken(int start, int end, int tokenType) {
    int so = start + offsetShift;
    addToken(zzBuffer, start,end, tokenType, so);
  }


  /**
   * Adds the token specified to the current linked list of tokens.
   *
   * @param array The character array.
   * @param start The starting offset in the array.
   * @param end The ending offset in the array.
   * @param tokenType The token's type.
   * @param startOffset The offset in the document at which this token
   *                    occurs.
   */
  @Override
  public void addToken(char[] array, int start, int end, int tokenType, int startOffset) {
    super.addToken(array, start,end, tokenType, startOffset);
    zzStartRead = zzMarkedPos;
  }


  /**
   * Returns the text to place at the beginning and end of a
   * line to "comment" it in a this programming language.
   *
   * @return The start and end strings to add to a line to "comment"
   *         it out.
   */
  @Override
  public String[] getLineCommentStartAndEnd(int languageIndex) {
    return new String[] { "//", null };
  }


  /**
   * Returns the first token in the linked list of tokens generated
   * from <code>text</code>.  This method must be implemented by
   * subclasses so they can correctly implement syntax highlighting.
   *
   * @param text The text from which to get tokens.
   * @param initialTokenType The token type we should start with.
   * @param startOffset The offset into the document at which
   *                    <code>text</code> starts.
   * @return The first <code>Token</code> in a linked list representing
   *         the syntax highlighted text.
   */
  public Token getTokenList(Segment text, int initialTokenType, int startOffset) {

    resetTokenList();
    this.offsetShift = -text.offset + startOffset;

    // Start off in the proper state.
    int state = Token.NULL;
    switch (initialTokenType) {
      case Token.COMMENT_MULTILINE:
        state = MLC;
        start = text.offset;
        break;
      default:
        state = Token.NULL;
    }

    s = text;
    try {
      yyreset(zzReader);
      yybegin(state);
      return yylex();
    } catch (IOException ioe) {
      ioe.printStackTrace();
      return new TokenImpl();
    }

  }


  /**
   * Refills the input buffer.
   *
   * @return      <code>true</code> if EOF was reached, otherwise
   *              <code>false</code>.
   * @exception   IOException  if any I/O-Error occurs.
   */
  private boolean zzRefill() throws java.io.IOException {
    return zzCurrentPos>=s.offset+s.count;
  }


  /**
   * Resets the scanner to read from a new input stream.
   * Does not close the old reader.
   *
   * All internal variables are reset, the old input stream 
   * <b>cannot</b> be reused (internal buffer is discarded and lost).
   * Lexical state is set to <tt>YY_INITIAL</tt>.
   *
   * @param reader   the new input stream 
   */
  public final void yyreset(java.io.Reader reader) throws java.io.IOException {
    // 's' has been updated.
    zzBuffer = s.array;
    /*
     * We replaced the line below with the two below it because zzRefill
     * no longer "refills" the buffer (since the way we do it, it's always
     * "full" the first time through, since it points to the segment's
     * array).  So, we assign zzEndRead here.
     */
    //zzStartRead = zzEndRead = s.offset;
    zzStartRead = s.offset;
    zzEndRead = zzStartRead + s.count - 1;
    zzCurrentPos = zzMarkedPos = zzPushbackPos = s.offset;
    zzLexicalState = YYINITIAL;
    zzReader = reader;
    zzAtBOL  = true;
    zzAtEOF  = false;
  }


%}

Letter              = [A-Za-z]
LetterOrUnderscore  = ({Letter}|[_])
Digit               = [0-9]
HexDigit            = {Digit}|[A-Fa-f]
OctalDigit          = [0-7]
Exponent            = [eE][+-]?{Digit}+

PreprocessorWord    = define|undef|if|ifdef|ifndef|else|elif|endif|error|pragma|extension|version|line

Trigraph            = ("??="|"??("|"??)"|"??/"|"??'"|"??<"|"??>"|"??!"|"??-")

OctEscape1          = ([\\]{OctalDigit})
OctEscape2          = ([\\]{OctalDigit}{OctalDigit})
OctEscape3          = ([\\][0-3]{OctalDigit}{OctalDigit})
OctEscape           = ({OctEscape1}|{OctEscape2}|{OctEscape3})
HexEscape           = ([\\][xX]{HexDigit}{HexDigit})

AnyChrChr           = ([^\'\n\\])
Escape              = ([\\]([abfnrtv\'\"\?\\0]))
UnclosedCharLiteral = ([\']({Escape}|{OctEscape}|{HexEscape}|{Trigraph}|{AnyChrChr}))
CharLiteral         = ({UnclosedCharLiteral}[\'])
ErrorUnclosedCharLiteral  = ([\'][^\'\n]*)
ErrorCharLiteral    = (([\'][\'])|{ErrorUnclosedCharLiteral}[\'])
AnyStrChr           = ([^\"\n\\])
FalseTrigraph       = (("?"(("?")*)[^\=\(\)\/\'\<\>\!\-\\\?\"\n])|("?"[\=\(\)\/\'\<\>\!\-]))
StringLiteral       = ([\"]((((("?")*)({Escape}|{OctEscape}|{HexEscape}|{Trigraph}))|{FalseTrigraph}|{AnyStrChr})*)(("?")*)[\"])
UnclosedStringLiteral     = ([\"]([\\].|[^\\\"])*[^\"]?)
ErrorStringLiteral        = ({UnclosedStringLiteral}[\"])


LineTerminator      = \n
WhiteSpace          = [ \t\f]

MLCBegin            = "/*"
MLCEnd              = "*/"
LineCommentBegin    = "//"

NonFloatSuffix      = (([uU][lL]?)|([lL][uU]?))
IntegerLiteral      = ({Digit}+{Exponent}?{NonFloatSuffix}?)
HexLiteral          = ("0"[xX]{HexDigit}+{NonFloatSuffix}?)
FloatLiteral        = ((({Digit}*[\.]{Digit}+)|({Digit}+[\.]{Digit}*)){Exponent}?[fFlL]?)
ErrorNumberFormat   = (({IntegerLiteral}|{HexLiteral}|{FloatLiteral}){NonSeparator}+)

NonSeparator        = ([^\t\f\r\n\ \(\)\{\}\[\]\;\,\.\=\>\<\!\~\?\:\+\-\*\/\&\|\^\%\"\']|"#")
Identifier          = ({LetterOrUnderscore}({LetterOrUnderscore}|{Digit}|[$])*)
ErrorIdentifier     = ({NonSeparator}+)


URLGenDelim         = ([:\/\?#\[\]@])
URLSubDelim         = ([\!\$&'\(\)\*\+,;=])
URLUnreserved       = ({LetterOrUnderscore}|{Digit}|[\-\.\~])
URLCharacter        = ({URLGenDelim}|{URLSubDelim}|{URLUnreserved}|[%])
URLCharacters       = ({URLCharacter}*)
URLEndCharacter     = ([\/\$]|{Letter}|{Digit})
URL                 = (((https?|f(tp|ile))"://"|"www.")({URLCharacters}{URLEndCharacter})?)

%state MLC
%state EOL_COMMENT

%%

<YYINITIAL> {

  /* Keywords */
  "attribute" |
  "const" |
  "uniform" |
  "varying" |
  "buffer" |
  "shared" |
  "coherent" |
  "volatile" |
  "restrict" |
  "readonly" |
  "writeonly" |
  "struct" |
  "layout" |
  "centroid" |
  "flat" |
  "smooth" |
  "noperspective" |
  "patch" |
  "sample" |
  "break" |
  "continue" |
  "do" |
  "for" |
  "while" |
  "switch" |
  "case" |
  "default" |
  "if" |
  "else" |
  "subroutine" |
  "in" |
  "out" |
  "inout" |
  "true" |
  "false" |
  "invariant" |
  "discard" |
  "return" |
  "lowp" |
  "mediump" |
  "highp" |
  "precision"       { addToken(Token.RESERVED_WORD); }

  /* Data types. */
  "sampler1D" |
  "sampler2D" |
  "sampler3D" |
  "samplerCube" |
  "sampler1DShadow" |
  "sampler2DShadow" |
  "samplerCubeShadow" |
  "sampler1DArray" |
  "sampler2DArray" |
  "sampler1DArrayShadow" |
  "sampler2DArrayShadow" |
  "isampler1D" |
  "isampler2D" |
  "isampler3D" |
  "isamplerCube" |
  "isampler1DArray" |
  "isampler2DArray" |
  "usampler1D" |
  "usampler2D" |
  "usampler3D" |
  "usamplerCube" |
  "usampler1DArray" |
  "usampler2DArray" |
  "sampler2DRect" |
  "sampler2DRectShadow" |
  "isampler2DRect" |
  "usampler2DRect" |
  "samplerBuffer" |
  "isamplerBuffer" |
  "usamplerBuffer" |
  "sampler2DMS" |
  "isampler2DMS" |
  "usampler2DMS" |
  "sampler2DMSArray" |
  "isampler2DMSArray" |
  "usampler2DMSArray" |
  "samplerCubeArray" |
  "samplerCubeArrayShadow" |
  "isamplerCubeArray" |
  "usamplerCubeArray" |
  "image1D" |
  "iimage1D" |
  "uimage1D" |
  "image2D" |
  "iimage2D" |
  "uimage2D" |
  "image3D" |
  "iimage3D" |
  "uimage3D" |
  "image2DRect" |
  "iimage2DRect" |
  "uimage2DRect" |
  "imageCube" |
  "iimageCube" |
  "uimageCube" |
  "imageBuffer" |
  "iimageBuffer" |
  "uimageBuffer" |
  "image1DArray" |
  "iimage1DArray" |
  "uimage1DArray" |
  "image2DArray" |
  "iimage2DArray" |
  "uimage2DArray" |
  "imageCubeArray" |
  "iimageCubeArray" |
  "uimageCubeArray" |
  "image2DMS" |
  "iimage2DMS" |
  "uimage2DMS" |
  "image2DMSArray" |
  "iimage2DMSArray" |
  "uimage2DMSArray" |
  "atomic_uint" |
  "mat2" |
  "mat3" |
  "mat4" |
  "dmat2" |
  "dmat3" |
  "dmat4" |
  "mat2x2" |
  "mat2x3" |
  "mat2x4" |
  "dmat2x2" |
  "dmat2x3" |
  "dmat2x4" |
  "mat3x2" |
  "mat3x3" |
  "mat3x4" |
  "dmat3x2" |
  "dmat3x3" |
  "dmat3x4" |
  "mat4x2" |
  "mat4x3" |
  "mat4x4" |
  "dmat4x2" |
  "dmat4x3" |
  "dmat4x4" |
  "vec2" |
  "vec3" |
  "vec4" |
  "ivec2" |
  "ivec3" |
  "ivec4" |
  "bvec2" |
  "bvec3" |
  "bvec4" |
  "dvec2" |
  "dvec3" |
  "dvec4" |
  "float" |
  "double" |
  "int" |
  "void" |
  "bool" |
  "uint" |
  "uvec2" |
  "uvec3" |
  "uvec4"           { addToken(Token.DATA_TYPE); }

  /* Standard functions */
  "radians" |
  "degrees" |
  "sin" |
  "cos" |
  "tan" |
  "asin" |
  "acos" |
  "atan" |
  "sinh" |
  "cosh" |
  "tanh" |
  "asinh" |
  "acosh" |
  "atanh" |
  "pow" |
  "exp" |
  "log" |
  "exp2" |
  "log2" |
  "sqrt" |
  "inversqrt" |
  "abs" |
  "sign" |
  "floor" |
  "trunc" |
  "round" |
  "roundEven" |
  "ceil" |
  "fract" |
  "mod" |
  "modf" |
  "min" |
  "max" |
  "clamp" |
  "mix" |
  "step" |
  "smoothstep" |
  "isnan" |
  "isinf" |
  "floatBitsToInt" |
  "floatBitsToUInt" |
  "intBitsToFloat" |
  "uintBitsToFloat" |
  "fma" |
  "frexp" |
  "ldexp" |
  "packUnorm2x16" |
  "packSnorm2x16" |
  "packUnorm4x8" |
  "packSnorm4x8" |
  "unpackUnorm2x16" |
  "unpackSnorm2x16" |
  "unpackUnorm4x8" |
  "unpackSnorm4x8 " |
  "packDouble2x32" |
  "unpackDouble2x32" |
  "packHalf2x16" |
  "unpackHalf2x16" |
  "length" |
  "distance" |
  "dot" |
  "cross" |
  "normalize" |
  "faceforward" |
  "reflect" |
  "refract" |
  "matrixCompMult" |
  "outerProduct" |
  "transpose" |
  "determinant" |
  "inverse" |
  "lessThan" |
  "lessThanEqual" |
  "greaterThan" |
  "greaterThanEqual" |
  "equal" |
  "notEqual" |
  "any" |
  "all" |
  "not" |
  "uaddCarry" |
  "usubBorrow" |
  "umulExtended" |
  "imulExtended" |
  "bitfieldExtract" |
  "bitfieldInsert" |
  "bitfieldReverse" |
  "findLSB" |
  "bitCount" |
  "findMSB" |
  "textureSize" |
  "textureQueryLod" |
  "textureQueryLevels" |
  "texture" |
  "textureProj" |
  "textureLod" |
  "textureOffset" |
  "texelFetch" |
  "texelFetchOffset" |
  "textureProjOffset" |
  "textureLodOffset" |
  "textureProjLod" |
  "textureProjLodOffset" |
  "textureGrad" |
  "textureGradOffset" |
  "textureProjGrad" |
  "textureProjGradOffset" |
  "textureGather" |
  "textureGatherOffset" |
  "textureGatherOffsets" |
  "texture1D " |
  "texture1DProj" |
  "texture1DLod" |
  "texture1DProjLod" |
  "texture2D" |
  "texture2DProj" |
  "texture2DLod" |
  "texture2DProjLod" |
  "texture3D" |
  "texture3DProj" |
  "texture3DLod" |
  "texture3DProjLod" |
  "textureCube" |
  "textureCubeLod" |
  "shadow1D" |
  "shadow2D" |
  "shadow1DProj" |
  "shadow2DProj" |
  "shadow1DLod" |
  "shadow2DLod" |
  "shadow1DProjLod" |
  "shadow2DProjLod" |
  "atomicCounterIncrement" |
  "atomicCounterDecrement" |
  "atomicCounter" |
  "atomicAdd" |
  "atomicMin" |
  "atomicMax" |
  "atomicAnd" |
  "atomicOr" |
  "atomicXor" |
  "atomicExchange" |
  "atomicCompSwap" |
  "imageSize" |
  "imageLoad" |
  "imageStore" |
  "imageAtomicAdd" |
  "imageAtomicMin" |
  "imageAtomicMax" |
  "imageAtomicAnd" |
  "imageAtomicOr" |
  "imageAtomicXor" |
  "imageAtomicExchange" |
  "imageAtomicCompSwap" |
  "dFdx" |
  "dFdy" |
  "fwidth" |
  "interpolateAtCentroid" |
  "interpolateAtSample" |
  "interpolateAtOffset" |
  "noise1" |
  "noise2" |
  "noise3" |
  "noise4" |
  "EmitStreamVertex" |
  "EndStreamPrimitive" |
  "EmitVertex" |
  "EndPrimitive" |
  "barrier" |
  "memoryBarrier" |
  "memoryBarrierAtomicCounter" |
  "memoryBarrierBuffer" |
  "memoryBarrierShared" |
  "memoryBarrierImage" |
  "groupMemoryBarrier"    { addToken(Token.FUNCTION); }

  /* Standard variables */
  "gl_NumWorkGroups" |
  "gl_WorkGroupSize" |
  "gl_WorkGroupID" |
  "gl_LocalInvocationID" |
  "gl_GlobalInvocationID" |
  "gl_LocalInvocationIndex" |
  "gl_VertexID" |
  "gl_InstanceID" |
  "gl_PerVertex " |
  "gl_Position" |
  "gl_PointSize" |
  "gl_ClipDistance" |
  "gl_in" |
  "gl_PrimitiveIDIn" |
  "gl_InvocationID" |
  "gl_Layer" |
  "gl_ViewportIndex" |
  "gl_PatchVerticesIn" |
  "gl_InvocationID" |
  "gl_out" |
  "gl_TessLevelOuter" |
  "gl_TessLevelInner" |
  "gl_PatchVerticesIn" |
  "gl_PrimitiveID" |
  "gl_TessCoord" |
  "gl_FragCoord" |
  "gl_FrontFacing" |
  "gl_ClipDistance" |
  "gl_PointCoord" |
  "gl_PrimitiveID" |
  "gl_SampleID" |
  "gl_SamplePosition" |
  "gl_SampleMaskIn" |
  "gl_Layer" |
  "gl_ViewportIndex" |
  "gl_FragDepth" |
  "gl_SampleMask"         { addToken(Token.VARIABLE); }

  /* Standard-defined macros. */
  "__DATE__" |
  "__TIME__" |
  "__FILE__" |
  "__LINE__" |
  "__STDC__"        { addToken(Token.PREPROCESSOR); }

  {LineTerminator}  { addNullToken(); return firstToken; }

  {Identifier}      { addToken(Token.IDENTIFIER); }

  {WhiteSpace}+     { addToken(Token.WHITESPACE); }

  /* Preprocessor directives */
  "#"{WhiteSpace}*{PreprocessorWord}  { addToken(Token.PREPROCESSOR); }

  /* String/Character Literals. */
  {CharLiteral}                       { addToken(Token.LITERAL_CHAR); }
  {UnclosedCharLiteral}               { addToken(Token.ERROR_CHAR); /*addNullToken(); return firstToken;*/ }
  {ErrorUnclosedCharLiteral}          { addToken(Token.ERROR_CHAR); addNullToken(); return firstToken; }
  {ErrorCharLiteral}                  { addToken(Token.ERROR_CHAR); }
  {StringLiteral}                     { addToken(Token.LITERAL_STRING_DOUBLE_QUOTE); }
  {UnclosedStringLiteral}             { addToken(Token.ERROR_STRING_DOUBLE); addNullToken(); return firstToken; }
  {ErrorStringLiteral}                { addToken(Token.ERROR_STRING_DOUBLE); }

  /* Comment Literals. */
  {MLCBegin}                          { start = zzMarkedPos-2; yybegin(MLC); }
  {LineCommentBegin}                  { start = zzMarkedPos-2; yybegin(EOL_COMMENT); }

  /* Separators. */
  "(" |
  ")" |
  "[" |
  "]" |
  "{" |
  "}"               { addToken(Token.SEPARATOR); }

  /* Operators. */
  {Trigraph} |
  "=" |
  "+" |
  "-" |
  "*" |
  "/" |
  "%" |
  "~" |
  "<" |
  ">" |
  "<<" |
  ">>" |
  "==" |
  "+=" |
  "-=" |
  "*=" |
  "/=" |
  "%=" |
  ">>=" |
  "<<=" |
  "^" |
  "&" |
  "&&" |
  "|" |
  "||" |
  "?" |
  ":" |
  "," |
  "!" |
  "++" |
  "--" |
  "." |
  ","               { addToken(Token.OPERATOR); }

  /* Numbers */
  {IntegerLiteral}    { addToken(Token.LITERAL_NUMBER_DECIMAL_INT); }
  {HexLiteral}        { addToken(Token.LITERAL_NUMBER_HEXADECIMAL); }
  {FloatLiteral}      { addToken(Token.LITERAL_NUMBER_FLOAT); }
  {ErrorNumberFormat} { addToken(Token.ERROR_NUMBER_FORMAT); }

  /* Some lines will end in '\' to wrap an expression. */
  "\\"                { addToken(Token.IDENTIFIER); }

  {ErrorIdentifier}   { addToken(Token.ERROR_IDENTIFIER); }

  /* Other punctuation, we'll highlight it as "identifiers." */
  ";"                 { addToken(Token.IDENTIFIER); }

  /* Ended with a line not in a string or comment. */
  <<EOF>>             { addNullToken(); return firstToken; }

  /* Catch any other (unhandled) characters and flag them as bad. */
  .                   { addToken(Token.ERROR_IDENTIFIER); }

}

<MLC> {

  [^hwf\n\*]+         {}
  {URL}               { int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_MULTILINE); addHyperlinkToken(temp,zzMarkedPos-1, Token.COMMENT_MULTILINE); start = zzMarkedPos; }
  [hwf]               {}

  \n                  { addToken(start,zzStartRead-1, Token.COMMENT_MULTILINE); return firstToken; }
  {MLCEnd}            { yybegin(YYINITIAL); addToken(start,zzStartRead+1, Token.COMMENT_MULTILINE); }
  \*                  {}
  <<EOF>>             { addToken(start,zzStartRead-1, Token.COMMENT_MULTILINE); return firstToken; }

}


<EOL_COMMENT> {
  [^hwf\n]+           {}
  {URL}               { int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_EOL); addHyperlinkToken(temp,zzMarkedPos-1, Token.COMMENT_EOL); start = zzMarkedPos; }
  [hwf]               {}
  \n                  { addToken(start,zzStartRead-1, Token.COMMENT_EOL); addNullToken(); return firstToken; }
  <<EOF>>             { addToken(start,zzStartRead-1, Token.COMMENT_EOL); addNullToken(); return firstToken; }
}
