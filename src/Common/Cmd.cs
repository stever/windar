﻿/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * Copyright (C) 2009, 2010 Steven Robertson <steve@playnode.org>
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

using System;
using System.Reflection;
using System.Threading;
using log4net;

namespace Windar.Common
{
    public abstract class Cmd<T> where T : new()
    {
        static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().ReflectedType);

        protected CmdRunner Runner { get; set; }

        protected bool Done { get; set; }

        protected Cmd()
        {
            Runner = new CmdRunner();
            Runner.CommandCompleted += Cmd_CommandCompleted;
        }

        public static T Create()
        {
            return new T();
        }

        protected void ContinueWhenDone()
        {
            if (Log.IsDebugEnabled) Log.Debug("Continue when done...");
            while (!Done) Thread.Sleep(100);
            if (Log.IsDebugEnabled) Log.Debug("Done.");
            Runner.Close();
            if (Log.IsDebugEnabled) Log.Debug("Runner closed.");
        }

        protected void Cmd_CommandCompleted(object sender, EventArgs e)
        {
            Done = true;
        }
    }
}