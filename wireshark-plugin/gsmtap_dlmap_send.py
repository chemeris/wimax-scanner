#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Program to send GSMTAP packets with DL-MAP's to Wireshark.
# Reads raw DL-MAP bits from stdin, one line per DL-MAP.
#
# Example:
#   cat bit.txt | ./gsmtap_dlmap_send.py
#
# Input data format:
# <burst_num> <burst_type> <length_in_subchannels> <bits>
# Example:
# 1 FCH 4 111111010010001010000000
#
# Copyright (C) 2011  Ivan Kluchnikov, Alexander Chemeris
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
# USA

from socket import socket, AF_INET, SOCK_DGRAM
import sys
import binascii

burst_type_map = {
'FCH'       : 0x11,  # WiMAX FCH burst
'DL-MAP'    : 0x13,  # WiMAX PDU burst
'DCD'       : 0x13,  # WiMAX PDU burst
'PDU'       : 0x13,  # WiMAX PDU burst
}

header_hex = '0104070100010101%08x%02x010100'

def send_gsmtap_packet(header_hex, burst_num, burst_type, payload_hex):
  data = header_hex%(burst_num, burst_type,) + payload_hex
  packet = binascii.a2b_hex(data)

  port = 4729
  hostname = '127.0.0.1'
  udp = socket(AF_INET,SOCK_DGRAM)
  udp.sendto(packet, (hostname, port))


for line in sys.stdin:
  str_parts = line.strip().split(' ')
  burst_num = int(str_parts[0])
  burst_type = burst_type_map[str_parts[1]]
  burst_subchannels = str_parts[2]
  burst_bin = str_parts[3]
  # The following crazy line converts a binary string to
  # a hex string. Double string substitution is needed to
  # correctly handle 0's at the string begining.
  burst_hex = ('%%0%dx' % (len(burst_bin)/4)) % int(burst_bin,2)
  send_gsmtap_packet(header_hex, burst_num, burst_type, burst_hex)

