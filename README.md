# croy-shark
Clash Royale protocol dissector for Wireshark

## How to?
To use it, simply copy those .lua files into your wireshark user plugin directory, and start a capture.

# Packet Structure

## Game Protocol Structure

**10 bytes** session id

**1 byte** ack length = *N1*

***N1* bytes** ack id

    for n1>0, followed by n1 bytes of seq no indicating which package it acknowledgs on

**1 byte** Data Field Count = *N2*

***N2* packets** data field

## Data Field structure

**1 byte** sequence id

**2 bytes** sender? 

    8e:d6:02 for server->client
    a8:c9:01 for client->server

**1 byte** field length = *N3*

**N3 bytes** data
