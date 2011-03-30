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

using System.Collections.Generic;

namespace Windar.PlayerPlugin
{
    class PlaydarResults
    {
        int _pollInterval;
        int _pollLimit;
        bool _solved;
        List<PlayItem> _playItems;

        public int PollInterval
        {
            get { return _pollInterval; }
            set { _pollInterval = value; }
        }

        public int PollLimit
        {
            get { return _pollLimit; }
            set { _pollLimit = value; }
        }

        public bool Solved
        {
            get { return _solved; }
            set { _solved = value; }
        }

        public List<PlayItem> PlayItems
        {
            get { return _playItems; }
            set { _playItems = value; }
        }

        public PlaydarResults()
        {
            PlayItems = new List<PlayItem>();
        }
    }
}
