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

using System.Text;

namespace Windar.Common
{
    public abstract class ShortCmd<T> : Cmd<T> where T : new()
    {
        readonly StringBuilder _stdOutput;
        readonly StringBuilder _stdErr;

        #region Properties

        public string Output
        {
            get { return _stdOutput.ToString(); }
        }

        public string Error
        {
            get { return _stdErr.ToString(); }
        }

        #endregion

        protected ShortCmd()
        {
            _stdOutput = new StringBuilder();
            _stdErr = new StringBuilder();
            Runner.CommandOutput += Cmd_CommandOutput;
            Runner.CommandError += Cmd_CommandError;
        }

        public abstract string Run();

        protected void Cmd_CommandOutput(object sender, CmdRunner.CommandEventArgs e)
        {
            _stdOutput.Append(e.Text).Append('\n');
        }

        protected void Cmd_CommandError(object sender, CmdRunner.CommandEventArgs e)
        {
            _stdErr.Append(e.Text).Append('\n');
        }
    }
}
