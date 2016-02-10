#!/usr/bin/python3

import socket
import sys
import time
import os
import inspect
from time import strftime
from lib.log import Log
import threading



class NewSpeakClient(NewSpeakBase, Log):
	def __init__(self, host, port):
		self.log = Log()
		self.host = host
		self.port = port
		try:
			self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
			self.log.info('Client socket created')
		except socket.error:
			self.log.error('Failed to create client socket')
			sys.exit()
		try:
			self.socket.connect((host, port))
			self.log.info('Connected to server')
		except socket.error:
			self.log.error('Failed to connect to server')
			sys.exit()

	def start_call(self):
		r = self.receive_data()
		self.send_data(bytes('disko', 'utf-8'))
		while True:
			r = self.receive_data()
			if self.data == 'CALL ACCEPTED':
				return True
				self.conversation()

	def accept_call(self):
		self.receive_data()
		if self.data == 'ACCEPT CALL?':
			self.send_data(bytes('ACCEPT CALL', 'utf-8'))
			return True
			self.conversation()
		else:
			self.log.info('No call to accept')
			self.receive_data()
			self.socket.close()
			return False

	def send_data(self, rawData):
		# TODO check if connection is still alive
		try:
			self.socket.sendall(rawData)
			return True
		except:
			self.log.error('Failed to send data')
			return False

	def receive_data(self):
		# TODO check if connection is still alive
		try:
			self.rawData = self.socket.recv(1024)
			self.decode()
			self.log.info('<<< %s'%self.data)
		except:
			self.log.error('Failed to receive data')
			sys.exit()
			return False
		if not self.data:
			sys.exit()

	def conversation(self):
		self.log.info('Start Conversation')
		# conversation() starts two threads and sends and receives from server
		receive = threading.Thread(name = 'conversation receive', target = self.conversation_receive_data)
		receive.setDaemon(True)
		send = threading.Thread(name = 'conversation send', target = self.conversation_send_data)
		send.setDaemon(True)
		receive.start()
		send.start()
		receive.join()
		send.join()

	def conversation_receive_data(self):
		while True:
			self.receive_data()

	def conversation_send_data(self):
		while True:
			userInput = input()
			self.send_data(bytes(userInput, 'utf-8'))
