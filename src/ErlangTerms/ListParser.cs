﻿using System.Reflection;
using log4net;

namespace Windar.ErlangTermsParser
{
    public class ListParser : Parser<ListToken>
    {
        private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().ReflectedType);

        public ListParser(ParserInputStream stream) : base(stream) { }

        #region State

        private enum State
        {
            Initial,
            ListOpen,
            SegmentBegin,
            SegmentEnd,
        }

        private State _state = State.Initial;

        private void ChangeState(State to)
        {
            if (Log.IsDebugEnabled)
            {
                Log.Debug(GetStateChangeMessage(_state.ToString(), to.ToString()));
            }
            _state = to;
        }

        #endregion

        internal static ListToken GetList(ParserInputStream stream)
        {
            return new ListParser(stream).NextToken();
        }

        public override ListToken NextToken()
        {
            ListToken result = new ListToken();
            int c;
            while ((c = InputStream.NextChar()) != -1)
            {
                switch (_state)
                {
                    case State.Initial:
                        {
                            switch ((char) c)
                            {
                                case '[':
                                    {
                                        ChangeState(State.ListOpen);
                                        break;
                                    }
                                default:
                                    {
                                        string msg = GetEdgeUnknownErrorMessage(c, _state.ToString());
                                        if (Log.IsErrorEnabled) Log.Error(msg);
                                        throw new ParserException(msg);
                                    }
                            }
                            break;
                        }
                    case State.ListOpen:
                        // NOTE: Same as SegmentBegin, except ']' is allowed here.
                        {
                            // Atom expression.
                            if (AtomParser.IsValidAtomFirstChar(c))
                            {
                                InputStream.PushBack(c);
                                result.Tokens.Add(AtomParser.GetAtom(InputStream));
                                ChangeState(State.SegmentEnd);
                                break;
                            }

                            // Numeric expression.
                            if (NumericExpressionParser.IsValidExpressionFirstChar(c))
                            {
                                InputStream.PushBack(c);
                                result.Tokens.Add(NumericExpressionParser.GetExpression(InputStream));
                                ChangeState(State.SegmentEnd);
                                break;
                            }

                            switch ((char) c)
                            {
                                case ']':
                                    {
                                        return result;
                                    }
                                case '\'':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(AtomParser.GetAtom(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '"':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(StringParser.GetString(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '{':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(TupleParser.GetTuple(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '[':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(GetList(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '%':
                                case ' ':
                                case '\t':
                                case '\n':
                                case '\r':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(WhitespaceParser.GetWhitespace(InputStream));
                                        break;
                                    }
                                default:
                                    {
                                        string msg = GetEdgeUnknownErrorMessage(c, _state.ToString());
                                        if (Log.IsErrorEnabled) Log.Error(msg);
                                        throw new ParserException(msg);
                                    }
                            }
                            break;
                        }
                    case State.SegmentBegin:
                        // NOTE: Same as ListOpen, except ']' is NOT allowed here.
                        {
                            // Atom expression.
                            if (AtomParser.IsValidAtomFirstChar(c))
                            {
                                InputStream.PushBack(c);
                                result.Tokens.Add(AtomParser.GetAtom(InputStream));
                                ChangeState(State.SegmentEnd);
                                break;
                            }

                            // Numeric expression.
                            if (NumericExpressionParser.IsValidExpressionFirstChar(c))
                            {
                                InputStream.PushBack(c);
                                result.Tokens.Add(NumericExpressionParser.GetExpression(InputStream));
                                ChangeState(State.SegmentEnd);
                                break;
                            }

                            switch ((char) c)
                            {
                                case '\'':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(AtomParser.GetAtom(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '"':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(StringParser.GetString(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '{':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(TupleParser.GetTuple(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '[':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(GetList(InputStream));
                                        ChangeState(State.SegmentEnd);
                                        break;
                                    }
                                case '%':
                                case ' ':
                                case '\t':
                                case '\n':
                                case '\r':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(WhitespaceParser.GetWhitespace(InputStream));
                                        break;
                                    }
                                default:
                                    {
                                        string msg = GetEdgeUnknownErrorMessage(c, _state.ToString());
                                        if (Log.IsErrorEnabled) Log.Error(msg);
                                        throw new ParserException(msg);
                                    }
                            }
                            break;
                        }
                    case State.SegmentEnd:
                        {
                            switch ((char) c)
                            {
                                case ',':
                                    {
                                        result.Tokens.Add(new CommaToken());
                                        ChangeState(State.SegmentBegin);
                                        break;
                                    }
                                case ']':
                                    {
                                        return result;
                                    }
                                case '%':
                                case ' ':
                                case '\t':
                                case '\n':
                                case '\r':
                                    {
                                        InputStream.PushBack(c);
                                        result.Tokens.Add(WhitespaceParser.GetWhitespace(InputStream));
                                        break;
                                    }
                                default:
                                    {
                                        string msg = GetEdgeUnknownErrorMessage(c, _state.ToString());
                                        if (Log.IsErrorEnabled) Log.Error(msg);
                                        throw new ParserException(msg);
                                    }
                            }
                            break;
                        }
                    default:
                        {
                            string msg = GetUnexpectedStateErrorMessage(_state.ToString());
                            throw new ParserException(msg);
                        }
                }
            }

            const string endmsg = "Unexpected end while parsing List. Partial token exception property.";
            if (Log.IsErrorEnabled) Log.Error(endmsg);
            throw new ParserException(endmsg, result);
        }
    }
}
