﻿/*************************************************************************
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * Copyright (C) 2009, 2010 Steven Robertson <steve@playnode.org>
 *
 * Windar: Playdar for Windows
 *
 * Windar is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * Windar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ************************************************************************/

using System.Text;

namespace Playnode.ErlangTerms.Parser
{
    public class StringToken : ParserToken, IValueToken
    {
        public string Text { get; set; }

        public StringToken()
        {
            
        }

        public StringToken(string text)
        {
            Text = text;
        }

        public override string ToString()
        {
            return new StringBuilder()
                .Append('"').Append(Text).Append('"').ToString();
        }
    }
}
