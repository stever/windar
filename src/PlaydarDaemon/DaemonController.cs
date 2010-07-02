/*
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
using log4net;
using Windar.Common;
using Windar.PlaydarDaemon.Commands;

namespace Windar.PlaydarDaemon
{
    public class DaemonController
    {
        static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().ReflectedType);

        #region Delegates and events.

        public delegate void PlaydarStartedHandler(object sender, EventArgs e);
        public delegate void PlaydarStartFailedHandler(object sender, EventArgs e);
        public delegate void PlaydarStoppedHandler(object sender, EventArgs e);
        public delegate void ScanCompletedHandler(object sender, EventArgs e);

        public event PlaydarStartedHandler PlaydarStarted;
        public event PlaydarStartFailedHandler PlaydarStartFailed;
        public event PlaydarStoppedHandler PlaydarStopped;
        public event ScanCompletedHandler ScanCompleted;

        #endregion

        #region Properties

        internal static DaemonController Instance { get; set; }

        internal WindarPaths Paths { get; set; }

        public bool Started { get; set; }

        public int NumFiles
        {
            get
            {
                var result = Cmd<NumFiles>.Create().Run();
                if (Log.IsDebugEnabled) Log.Debug("NumFiles result = " + result.Trim());
                try
                {
                    return Int32.Parse(result);
                }
                catch (FormatException)
                {
                    //TODO: Try to create a useful error message.
                    throw new Exception(result);
                }
            }
        }

        #endregion

        public DaemonController(WindarPaths paths)
        {
            Paths = paths;
            Instance = this;
            Started = false;

            // Create user AppData files if necessary.
            Cmd<InitAppData>.Create().Run();
        }

        #region Commands

        public void Start()
        {
            var cmd = Cmd<Start>.Create();
            cmd.PlaydarStarted += StartCmd_PlaydarStarted;
            cmd.PlaydarStartFailed += StartCmd_PlaydarStartFailed;
            cmd.RunAsync();
            Started = true;
            System.Threading.Thread.Sleep(500);
        }

        public void Stop()
        {
            Cmd<Stop>.Create().Run();
            Started = false;
            PlaydarStopped(this, new EventArgs());
            System.Threading.Thread.Sleep(1000);
        }

        public void Restart()
        {
            if (Started) Stop();
            Start();
        }

        public string Ping()
        {
            return Cmd<Ping>.Create().Run();
        }

        public string Status()
        {
            return Cmd<Status>.Create().Run();
        }

        public string DumpLibrary()
        {
            return Cmd<DumpLibrary>.Create().Run();
        }

        public void Scan(string path)
        {
            var cmd = Cmd<Scan>.Create();
            cmd.ScanCompleted += ScanCmd_ScanCompleted;
            cmd.ScanPath = path;
            cmd.RunAsync();
        }

        #endregion

        #region Command event handlers.

        void StartCmd_PlaydarStarted(object sender, EventArgs e)
        {
            Started = true;
            PlaydarStarted(this, e);
        }

        void StartCmd_PlaydarStartFailed(object sender, EventArgs e)
        {
            Started = false;
            PlaydarStartFailed(this, e);
        }

        void ScanCmd_ScanCompleted(object sender, EventArgs e)
        {
            ScanCompleted(this, e);
        }

        #endregion
    }
}