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

using System.Text;

namespace Windar.TrayApp.Configuration
{
    public class PeerInfo
    {
        string _host;
        int _port;
        bool _share;

        protected bool HostChanged { get; set; }
        protected bool PortChanged { get; set; }
        protected bool ShareChanged { get; set; }

        public string Host
        {
            get
            {
                return _host;
            }
            set
            {
                HostChanged = _host != value;
                _host = value;
            }
        }

        public int Port
        {
            get
            {
                return _port;
            }
            set
            {
                PortChanged = _port != value;
                _port = value;
            }
        }

        public bool Share
        {
            get
            {
                return _share;
            }
            set
            {
                // Always true if this property is ever set.
                // Because it's an optional property.
                ShareChanged = true;
                _share = value;
            }
        }

        public PeerInfo(string host, int port)
        {
            _host = host;
            _port = port;
        }

        public PeerInfo(string host, int port, bool share)
        {
            _host = host;
            _port = port;
            _share = share;
        }

        protected bool IsChanged()
        {
            return HostChanged || PortChanged || ShareChanged;
        }

        public override string ToString()
        {
            var result = new StringBuilder();
            result.Append("{\"").Append(_host).Append("\", ").Append(_port).Append("}");
            return result.ToString();
        }
    }
}
