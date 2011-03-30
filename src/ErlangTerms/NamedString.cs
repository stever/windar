﻿/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * Copyright (C) 2009, 2010, 2011 Steven Robertson <steve@playnode.com>
 *
 * Windar - Playdar for Windows
 *
 * Windar is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License (LGPL) as published
 * by the Free Software Foundation; either version 2.1 of the License, or (at
 * your option) any later version.
 *
 * Windar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License version 2.1 for more details
 * (a copy is included in the LICENSE file that accompanied this code).
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using System.Reflection;
using log4net;

namespace Playnode.ErlangTerms.Parser
{
    public class NamedString : NamedValue
    {
        private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().ReflectedType);

        public new string Value
        {
            get
            {
                return ((StringToken) base.Value).Text;
            }
            set
            {
                base.Value = new StringToken(value);
            }
        }

        public NamedString(string name, string value) : base(name)
        {
            Tokens.Add(new StringToken(value));
        }

        /// <summary>
        /// This method will return null if the given tuple is not found to be
        /// suitable. A suitable tuple would have a single value, and a single
        /// atom as first part of the tuple.
        /// </summary>
        /// <param name="tuple">Tuple to use in creating a NamedString instance.</param>
        /// <returns>An instance of NamedString based on the give tuple.</returns>
        public static new NamedString CreateFrom(TupleToken tuple)
        {
            if (Log.IsDebugEnabled) Log.Debug("Trying to create a NamedString from tuple = " + tuple);

            NamedString result = null;
            string name = null;
            bool foundName = false;
            foreach (ParserToken tupleToken in tuple.Tokens)
            {
                // Seek out the first value token, ignoring spaces.
                if (!(tupleToken is IValueToken)) continue;

                if (!foundName)
                {
                    // We're expecting the atom to be the first value token.
                    // Otherwise, quit and return false.
                    if (!(tupleToken is AtomToken)) break;

                    // Store the name and look for the value.
                    name = ((AtomToken) tupleToken).Text;
                    if (Log.IsDebugEnabled) Log.Debug("Found name = " + name);
                    foundName = true;
                    continue;
                }

                // We're expecting a string to be the next value token.
                // Otherwise, quit and return false.
                if (!(tupleToken is StringToken)) break;

                // Create the NamedString instance and return.
                string value = ((StringToken) tupleToken).Text;
                result = new NamedString(name, value);
                result.Tokens = tuple.Tokens;
                break;
            }
            return result;
        }
    }
}
