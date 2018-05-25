% sender = UDPSender(port)
% Create a sender for UDP packages at the given port.
% 
% UDPSender methods:
%   send - Send a UDP package.

% 2016-12-02. Leonardo Molina.
% 2018-03-22. Last modified.
classdef UDPSender
    properties (Access = private)
        mPort
        mSocket
    end
    
    properties (Dependent)
        port
    end
    
    methods
        function obj = UDPSender(port)
            % UDPSender.UDPSender(port)
            % Create a UDP sender at the given port.
            
            obj.mPort = port;
            obj.mSocket = java.net.DatagramSocket;
            obj.mSocket.setReuseAddress(true);
        end
        
        function send(obj, messages, addresses)
            % UDPSender.Send(message, IP)
            % UDPSender.Send({message1, message2, ...}, IP)
            % UDPSender.Send(message, {IP1, IP2, ...})
            % UDPSender.Send({message1, message2, ..., messageN}, {IP1, IP2, ..., IPN})
            % Send one or more messages to one or more IP addresses.
            
            if ~iscell(addresses)
                addresses = {addresses};
            end
            if iscell(messages)
                for m = 1:numel(messages)
                    messages{m} = cast(messages{m}, 'uint8');
                end
            else
                messages = {cast(messages, 'uint8')};
            end
            nMessages = numel(messages);
            nAddresses = numel(addresses);
            if nMessages > nAddresses
                addresses = repmat(addresses, 1, nMessages);
            elseif nMessages < nAddresses
                messages = repmat(messages, 1, nAddresses);
            end
            
            for m = 1:numel(addresses)
                hostName = java.lang.String(addresses{m});
                jInetAddress = java.net.InetAddress.getByName(hostName);
                packet = java.net.DatagramPacket(messages{m}, numel(messages{m}), jInetAddress, obj.mPort);
                obj.mSocket.send(packet);
            end
        end
        
        function delete(obj)
            % UDPSender.delete(obj)
            % Release internal mSocket.
            obj.mSocket.close();
        end
    end
end