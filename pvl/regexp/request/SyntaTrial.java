/* Generated By:JavaCC: Do not edit this line. SyntaTrial.java */
package eurogate.pvl.regexp.request;

import java.util.Hashtable;
import java.io.StringReader;

/** class SyntaTrial checks the syntax of a requestExpression
 *  and builds a Hashtable.
 *  The requestExpression is stored in the class Request as a String.
 *  The request passes a StringReader into SyntaTrial. 
 *  The Hashtable is later used by class RegFitCheck.
 */
public class SyntaTrial implements SyntaTrialConstants {
  private static final Boolean FALSE= Boolean.FALSE;
  private static final Boolean TRUE= Boolean.TRUE;

  private java.util.Hashtable _requestAssigns = new java.util.Hashtable();
  private java.util.Stack _argStack = new java.util.Stack();

 /** createTable stores the data of the requestExpression into a Hashtable.
  *  input is gifen to its class. 
  *  output is the Hashtable.
  *  ParseException and TokenMgrError are thrown
  *  if the expression contains errors.
  */
  public Hashtable createTable() throws ParseException,
                                        TokenMgrError{
    while(getToken(1).kind != EOF){
      requestExpression();
    }

    return _requestAssigns;
  }

  final public void requestExpression() throws ParseException {
    label_1:
    while (true) {
      assignment();
      switch ((jj_ntk==-1)?jj_ntk():jj_ntk) {
      case NAME:
        ;
        break;
      default:
        jj_la1[0] = jj_gen;
        break label_1;
      }
    }
  }

  final public void assignment() throws ParseException {
 String key= null;
    jj_consume_token(NAME);
             key= token.image;
    jj_consume_token(ASSIGN);
    value();
    jj_consume_token(SEMICOLON);
                  _requestAssigns.put(key, _argStack.pop());
  }

  final public void value() throws ParseException {
    switch ((jj_ntk==-1)?jj_ntk():jj_ntk) {
    case ANYNAME:
      jj_consume_token(ANYNAME);
                            _argStack.push(
                              token.image.substring(1,(token.image.length()-1)) );
      break;
    case NAME:
      jj_consume_token(NAME);
                         _argStack.push(token.image);
      break;
    case FLOAT:
      jj_consume_token(FLOAT);
                          _argStack.push(Float.valueOf(token.image));
      break;
    case ZEROINT:
      jj_consume_token(ZEROINT);
                           _argStack.push(Integer.valueOf(token.image,10) );
      break;
    case INTEGER:
      jj_consume_token(INTEGER);
                            _argStack.push(Integer.valueOf(token.image,10));
      break;
    case OCTINTEGER:
      jj_consume_token(OCTINTEGER);
                               _argStack.push(
                                 Integer.valueOf(token.image.substring(1),8));
      break;
    case HEXINTEGER:
      jj_consume_token(HEXINTEGER);
                               _argStack.push(
                                Integer.valueOf(token.image.substring(2),16));
      break;
    default:
      jj_la1[1] = jj_gen;
      jj_consume_token(-1);
      throw new ParseException();
    }
  }

  public SyntaTrialTokenManager token_source;
  ASCII_CharStream jj_input_stream;
  public Token token, jj_nt;
  private int jj_ntk;
  private int jj_gen;
  final private int[] jj_la1 = new int[2];
  final private int[] jj_la1_0 = {0x100,0x3f80,};

  public SyntaTrial(java.io.InputStream stream) {
    jj_input_stream = new ASCII_CharStream(stream, 1, 1);
    token_source = new SyntaTrialTokenManager(jj_input_stream);
    token = new Token();
    jj_ntk = -1;
    jj_gen = 0;
    for (int i = 0; i < 2; i++) jj_la1[i] = -1;
  }

  public void ReInit(java.io.InputStream stream) {
    jj_input_stream.ReInit(stream, 1, 1);
    token_source.ReInit(jj_input_stream);
    token = new Token();
    jj_ntk = -1;
    jj_gen = 0;
    for (int i = 0; i < 2; i++) jj_la1[i] = -1;
  }

  public SyntaTrial(java.io.Reader stream) {
    jj_input_stream = new ASCII_CharStream(stream, 1, 1);
    token_source = new SyntaTrialTokenManager(jj_input_stream);
    token = new Token();
    jj_ntk = -1;
    jj_gen = 0;
    for (int i = 0; i < 2; i++) jj_la1[i] = -1;
  }

  public void ReInit(java.io.Reader stream) {
    jj_input_stream.ReInit(stream, 1, 1);
    token_source.ReInit(jj_input_stream);
    token = new Token();
    jj_ntk = -1;
    jj_gen = 0;
    for (int i = 0; i < 2; i++) jj_la1[i] = -1;
  }

  public SyntaTrial(SyntaTrialTokenManager tm) {
    token_source = tm;
    token = new Token();
    jj_ntk = -1;
    jj_gen = 0;
    for (int i = 0; i < 2; i++) jj_la1[i] = -1;
  }

  public void ReInit(SyntaTrialTokenManager tm) {
    token_source = tm;
    token = new Token();
    jj_ntk = -1;
    jj_gen = 0;
    for (int i = 0; i < 2; i++) jj_la1[i] = -1;
  }

  final private Token jj_consume_token(int kind) throws ParseException {
    Token oldToken;
    if ((oldToken = token).next != null) token = token.next;
    else token = token.next = token_source.getNextToken();
    jj_ntk = -1;
    if (token.kind == kind) {
      jj_gen++;
      return token;
    }
    token = oldToken;
    jj_kind = kind;
    throw generateParseException();
  }

  final public Token getNextToken() {
    if (token.next != null) token = token.next;
    else token = token.next = token_source.getNextToken();
    jj_ntk = -1;
    jj_gen++;
    return token;
  }

  final public Token getToken(int index) {
    Token t = token;
    for (int i = 0; i < index; i++) {
      if (t.next != null) t = t.next;
      else t = t.next = token_source.getNextToken();
    }
    return t;
  }

  final private int jj_ntk() {
    if ((jj_nt=token.next) == null)
      return (jj_ntk = (token.next=token_source.getNextToken()).kind);
    else
      return (jj_ntk = jj_nt.kind);
  }

  private java.util.Vector jj_expentries = new java.util.Vector();
  private int[] jj_expentry;
  private int jj_kind = -1;

  final public ParseException generateParseException() {
    jj_expentries.removeAllElements();
    boolean[] la1tokens = new boolean[14];
    for (int i = 0; i < 14; i++) {
      la1tokens[i] = false;
    }
    if (jj_kind >= 0) {
      la1tokens[jj_kind] = true;
      jj_kind = -1;
    }
    for (int i = 0; i < 2; i++) {
      if (jj_la1[i] == jj_gen) {
        for (int j = 0; j < 32; j++) {
          if ((jj_la1_0[i] & (1<<j)) != 0) {
            la1tokens[j] = true;
          }
        }
      }
    }
    for (int i = 0; i < 14; i++) {
      if (la1tokens[i]) {
        jj_expentry = new int[1];
        jj_expentry[0] = i;
        jj_expentries.addElement(jj_expentry);
      }
    }
    int[][] exptokseq = new int[jj_expentries.size()][];
    for (int i = 0; i < jj_expentries.size(); i++) {
      exptokseq[i] = (int[])jj_expentries.elementAt(i);
    }
    return new ParseException(token, exptokseq, tokenImage);
  }

  final public void enable_tracing() {
  }

  final public void disable_tracing() {
  }

}
