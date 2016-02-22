#!/usr/bin/python3

try:
    import sys,os

#    from matplotlib import style
#    import matplotlib.pyplot as plt
#    import matplotlib.animation as animation
#    import matplotlib.dates as dates
    import pyqtgraph as pg
    from pyqtgraph.Qt import QtCore, QtGui
    import numpy as np


    import threading

    import datetime
    import socket
    import select
    import time

    import inspect
    import re
    from time import strftime
except ImportError as e:
    print('failed to import: {0}'.format(e))
    sys.exit()


class StoppableThread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.stop_flag = threading.Event()

    def stop(self):
        if self.isAlive() == True:
            self.stop_flag.set()

    def stopped(self):
        return self.stop_flag.is_set()



class Log(object):
    def __init__(self, logfile=False, level='debug', display=True, maxlength=20):
        self.logfile = logfile
        self.display = display
        self.level = level
        self.maxlength = maxlength

        self.colors = { 'red'    : '\033[31m',
                        'white'  : '\033[37m',
                        'gray'   : '\033[0m',
                        'orange' : '\033[33m',
                        'blue'   : '\033[34m',
                        'green'  : '\033[32m',
                        'reset'  : '\033[0m' }

        self.colors_levels = { 'info'    : 'white',
                               'error'   : 'red',
                               'debug'   : 'gray',
                               'warning' : 'orange' }

        self.custom_highlights = {}


    def choose_show(self, level):
        """ Decide if a message should be shown based on configured message level """
        if self.level == 'error' and (level == 'debug' or level == 'warning' or level == 'info'):
            return False
        if self.level == 'warning' and (level =='debug' or level == 'info'):
            return False
        if self.level == 'info' and (level == 'debug'):
            return False
        return True


    def create_message(self, level, module, message):
        # TODO: Add feature to detect lists/dicts and print them out nicely
        if self.choose_show(level):
            message = self.detect_type(message)
            module_justified = module.ljust(self.maxlength)
            level_justified = level.ljust(7)
            time = strftime("%H:%M:%S")

            if self.display:
                print("{0} {1} {2} {3}".format(module_justified,
                                               self.colors[self.colors_levels[level]],
                                               self.custom_highlight(message, self.colors[self.colors_levels[level]]),
                                               self.colors['reset']))

            if self.logfile:
                self.write_to_file("{0} {1}{2}{3}\n".format(strftime("%Y-%m-%d %H:%M:%S"),
                                                            level_justified,
                                                            module_justified,
                                                            message))


    def detect_type(self, message):
        """ Detect whether message is list or dict """
        if type(message) == list:
            message = ' , '.join(message)
        elif type(message) == dict:
            message_out = ''
            for k,v in message.items():
                message_out = "{0}\n{1} : {2}".format(message_out,k,v)
            message = message_out
        return message


    def create_file(self):
        """ Create a file if it doesn't exist """
        try:
            with open(self.logfile) as f: pass
        except IOError as e:
            try:
                FILE = open(self.logfile, 'w')
                FILE.close()
            except IOError as e:
                print('WARNING ... Couldn\'t create file \'%s\' Not writing logs!'%self.logfile)
                return False
        return True


    def write_to_file(self, message):
        if self.create_file():
            try:
                FILE = open(self.logfile, 'a')
                FILE.write(message)
                FILE.close()
            except:
                print('Failed to write to logfile')


    def custom_highlight(self, message, reset_color):
        if message:
            for string, color in self.custom_highlights.items():
                message = re.sub( string, self.colors[color] + string + reset_color, message)
        return message


    def color(self, string, color):
        """ Callable method to add a custom highlight eg. ( log.color('what_to_highlight', 'color_to_use') ) """
        self.custom_highlights[string] = color


    def info(self, message):
        self.create_message('info', inspect.stack()[1][3], message)


    def debug(self, message):
        self.create_message('debug', inspect.stack()[1][3], message)


    def warning(self, message):
        self.create_message('warning', inspect.stack()[1][3], message)


    def error(self, message):
        self.create_message('error', inspect.stack()[1][3], message)


    def red(self, message):
        self.create_message('info', inspect.stack()[1][3], message)


    def blue(self, message):
        self.create_message('info', inspect.stack()[1][3], message)


    def green(self, message):
        self.create_message('info', inspect.stack()[1][3], message)


    def orange(self, message):
        self.create_message('info', inspect.stack()[1][3], message)



class Config_Option(object):
    """ Helper class of Config() """
    def __init__(self, section=False, comment=[], key=False, value=False):
        self.section = section
        self.key = key
        self.value = value
        if comment:
            if type(comment) == list:
                self.comment = comment
            else:
                self.comment = [comment]
        else:
            self.comment = []

    def set_comment(self, comment): 
        if type(comment) == list:
            self.comment = comment
        else:
            self.comment = [comment]

    def set_section(self, section): self.section = section
    def set_key(self, key): self.key = value
    def set_value(self, value): self.value = value
    def get_section(self): return self.section
    def get_comment(self): return self.comment
    def get_key(self): return self.key
    def get_value(self): return self.value



class Config(object):
    def __init__(self, quiet=False):
        self.config_file_path = False
        # This list stores all config option objects
        self.config = []
        # display errrors
        self.quiet = quiet


    def set_option(self, option): self.config.append(option)
    def set_config_path(self, path): self.config_file_path = path
    def get_options(self): return sorted(self.config, key=lambda x: x.get_section(), reverse=False)
    def get_config_path(self): return self.config_file_path


    def test_float(self, var):
        try:
            return float(var)
        except:
            return False


    def test_int(self, var):
        try:
            return int(var)
        except:
            return False


    def convert_numbers(self, var):
        """ Convert strings or lists of numbers to floats or ints """
        # var is a list
        if type(var) == list:

            for x in range(0, len(var)):
                if self.test_int(var[x]):
                    var[x] = self.test_int(var[x])
                elif self.test_float(var[x]):
                    var[x] = self.test_float(var[x])

        # Var is not a list
        else:
            if self.test_int(var):
                var = int(var)
            elif self.test_float(var):
                var = float(var)

        return var


    def parse_file(self, path):
        """ Parse file and create a list with option objects """

        # Get config file contents in a list
        section = False
        comments = []

        config_file = self.get_file()

        if not config_file:
            return False

        for line in config_file:
            # clean line from whitespaces, newlines etc
            line = self.sanitize(line)

            # Line is empty, do nothing
            if not line:
                pass

            # Line is commented
            elif line[0] == '#':
                comments.append(self.sanitize(line[1:]))

            # Line is a section header
            elif line[0] == '[' and line[-1] == ']':
                section = self.sanitize(line, extra_opts = ['[', ']'])

            # We are in a section loop
            elif section:

                # Line is a key/value pair
                if '=' in line:
                    k,v = line.split('=', 1)
                    k = self.sanitize(k)
                    v = self.sanitize(v)

                    # replace certain values like ~ -> /home/<user>
                    v = self.replace(v)
                    # TODO Find a solution for this, the replaced variable should not be written back to the file
                    #      Also does this not work for variables set by config.set()

                    # Value is empty, add empty value
                    if not v:
                        option = self.set(section, k, '', comment=comments)
                        comments = []


                    # Value is a list
                    elif v[0] == '[' and v[-1] == ']':
                        v = self.sanitize(v, extra_opts = ['[', ']'])

                        # Value contains a comma. read all values in a list
                        if ',' in v:
                            v_list = self.sanitize_list(v.split(','))
                            option = self.set(section, k, v_list, comment=comments)
                            comments = []


                        # Value doesn't contain comma so could be a list with a single item or an empty list
                        else:
                            if v:
                                option = self.set(section, k, v, comment=comments)
                            else:
                                option = self.set(section, k, [], comment=comments)
                            comments = []

                    # Value is a simple key, value pair
                    else:
                        option = self.set(section, k, v, comment=comments)
                        comments = []

        return self.config


    def set(self, section, k, v, comment=[]):
        """ Create a config_option() instance and fill it with data """
        v = self.convert_numbers(v)
        # If option already exist, change it
        for option in self.get_options():
            if option.get_section() == section:
                if option.get_key() == k:
                    option.set_comment(comment)
                    option.set_value(v)
                    return option
        # If option does not exist, create it
        option = Config_Option(key=k, value=v, section=section, comment=comment)
        self.set_option(option)
        return option


    def get(self, section, key):
        """ Get a value from list of config_option() instances in self.config by section and key """
        for option in self.get_options():
            if option.get_section() == section:
                if option.get_key() == key:
                    return option.get_value()
        if not self.quiet:
            print('Couldn\'t find value for key in section {0} : {1}'.format(section, key))
        return False


    def test_file(self):
        """ Test if file exists """
        try:
            with open(self.config_file_path) as f: pass
            return True
        except IOError as e:
            return False


    def ensure_dir(self, dirname):
        if not os.path.exists(dirname):
            os.makedirs(dirname)


    def write_to_file(self, data=False, remove=False):
        """ Write a string to a file, remove file if it exists by giving remove=False """
        if not self.get_config_path():
            return False

        self.ensure_dir(os.path.dirname(self.get_config_path()))

        if remove == True:
            try:
                FILE = open(self.config_file_path, 'w')
                FILE.close()
                return True
            except:
                if not self.quiet:
                    print('Failed to remove file')
                return False

        else:
            try:
                FILE = open(self.config_file_path, 'a')
                FILE.write(data + '\n')
                FILE.close()
                return True
            except:
                if not self.quiet:
                    print('Failed to write to file')
                pass
        return False


    def write(self):
        """ Write the config to disk """

        self.write_to_file(remove=True)
        section = False
        first = True

        for option in self.get_options():
            current_section = option.get_section()

            if not current_section == section:
                # Only put newline above section header if it is not the first one
                if first:
                    self.write_to_file('[{0}]'.format(current_section))
                    first = False
                else:
                    self.write_to_file('\n[{0}]'.format(current_section))
                section = current_section

            comment = option.get_comment()
            for c in comment:
                self.write_to_file('# {0}'.format(c))

            value = option.get_value()
            if type(value) == list:
                value = '[{0}]'.format(','.join(value))

            self.write_to_file('{0} = {1}'.format(option.get_key(),value))
        if not self.quiet:
            print('File written to: {0}'.format(self.config_file_path))


    def get_file(self):
        """ Get contents of a file and put every line in a list"""
        contents = []
        try:
            f = open(self.config_file_path, 'r')
        except IOError as e:
            if not self.quiet:
                print('No config file found at: {0}'.format(self.config_file_path))
            return False

        for line in f:
            if line:
                contents.append(self.sanitize(line))
        f.close()

        if contents:
            return contents
        return False


    def sanitize(self, data, extra_opts = []):
        """ Clean variable from newlines, leading/trailing spaces and other stuff """
        sanitize_list = [' ', '\'', '\"', '\n'] + extra_opts
        for sanitize in sanitize_list:
            data = data.strip(sanitize)
        return data


    def sanitize_list(self, data):
        """ Clean list indices from newlines, leading/trailing spaces and other stuff """
        output = []
        for x in data:
            x = x.strip()
            x = x.strip('\'')
            x = x.strip('\"')
            x = x.strip('\n')
            x = x.strip('[')
            x = x.strip(']')
            output.append(x)
        data = output[:]
        return data


    def replace(self, data):
        """ Replace characters or strings in a string with something else """
        replace_list = {'~' : os.getenv("HOME"), '<HOSTNAME>' : socket.gethostname()}
        for k,v in replace_list.items():
            data = data.replace(k, v)
        return data


    def parse(self):
        # Parse the config file
        if self.parse_file(self.config_file_path):
            return True
        return False



class ADS1299(object):
    def __init__(self):
        self.registers = {}
        self.registers['ID']          = 0x00
        self.registers['CONFIG1']     = 0x01
        self.registers['CONFIG2']     = 0x02
        self.registers['CONFIG3']     = 0x03
        self.registers['LOFF']        = 0x04
        self.registers['CH1SET']      = 0x05
        self.registers['CH2SET']      = 0x06
        self.registers['CH3SET']      = 0x07
        self.registers['CH4SET']      = 0x08
        self.registers['CH5SET']      = 0x09
        self.registers['CH6SET']      = 0x0A
        self.registers['CH7SET']      = 0x0B
        self.registers['CH8SET']      = 0x0C
        self.registers['BIAS_SENSP']  = 0x0D
        self.registers['BIAS_SENSN']  = 0x0E
        self.registers['LOFF_SENSP']  = 0x0F
        self.registers['LOFF_SENSN']  = 0x10
        self.registers['LOFF_FLIP']   = 0x11
        self.registers['LOFF_STATP']  = 0x12
        self.registers['LOFF_STATN']  = 0x13
        self.registers['GPIO']        = 0x14
        self.registers['MISC1']       = 0x15
        self.registers['MISC2']       = 0x16
        self.registers['CONFIG4']     = 0x17

        self.values = {}
        self.values['ID']          = list('00011110')
        self.values['CONFIG1']     = list('10010110')
        self.values['CONFIG2']     = list('11000000')
        self.values['CONFIG3']     = list('01100000')
        self.values['LOFF']        = list('00000000')
        self.values['CH1SET']      = list('01100000')
        self.values['CH2SET']      = list('01100000')
        self.values['CH3SET']      = list('01100000')
        self.values['CH4SET']      = list('01100000')
        self.values['CH5SET']      = list('01100000')
        self.values['CH6SET']      = list('01100000')
        self.values['CH7SET']      = list('01100000')
        self.values['CH8SET']      = list('01100000')
        self.values['BIAS_SENSP']  = list('00000000')
        self.values['BIAS_SENSN']  = list('00000000')
        self.values['LOFF_SENSP']  = list('00000000')
        self.values['LOFF_SENSN']  = list('00000000')
        self.values['LOFF_FLIP']   = list('00000000')
        self.values['LOFF_STATP']  = list('00000000')
        self.values['LOFF_STATN']  = list('00000000')
        self.values['GPIO']        = list('00001111')
        self.values['MISC1']       = list('00000000')
        self.values['MISC2']       = list('00000000')
        self.values['CONFIG4']     = list('00000000')


    def get_reg(self, reg):
        return '0x{:02x}'.format(self.registers[reg]), hex(int(''.join(self.values[reg]),2))


    def get_all_regs(self):
        return_list = []
        for reg in self.registers:
            return_list.append(self.get_reg(reg))
        return return_list



    def get_reg_bak(self, reg):
        ret_reg = hex(self.registers[reg])
        v= ''.join(self.values[reg])
        #v= hex(int(''.join(self.values[reg]), 2))
        #value = '0x{:02x}'.format(v)
        print(ba.hexlify(v.encode()))
        return ret_reg,v


    def set_reg(self, reg, bit, value):
        self.values[reg][bit-1] = str(value)
        return self.get_reg(reg)


    def set_channel(self, channel, state=True):
        # Enable/disable channel
        if state:
            log.info('Enabling channel: {0}'.format(channel))
            return self.set_reg('CH{0}SET'.format(str(channel)), 1, 0)
        else:
            log.info('Disabling channel: {0}'.format(channel))
            return self.set_reg('CH{0}SET'.format(str(channel)), 1, 1)


    def set_srb1(self, state=True):
        # Enable/disable channel
        if state:
            log.info('Setting SRB1 as ground on all channels')
            return self.set_reg('MISC1', 3, 1)
        else:
            log.info('Disconnecting SRB1')
            return self.set_reg('MISC1', 3, 0)


    def set_internal_ref(self, state=True):
        # Enable/disable channel
        if state:
            log.info('Using internal reference')
            return self.set_reg('CONFIG3', 1, 1)
        else:
            log.info('Using external reference')
            return self.set_reg('CONFIG3', 1, 0)


    def set_gain(self, channel, level):
        gain = {}
        gain[1] = list('000')
        gain[2] = list('001')
        gain[4] = list('010')
        gain[6] = list('011')
        gain[8] = list('100')
        gain[12] = list('101')
        gain[24] = list('110')

        self.set_reg('CH{0}SET'.format(str(channel)), 2, gain[level][0])
        self.set_reg('CH{0}SET'.format(str(channel)), 3, gain[level][1])
        self.set_reg('CH{0}SET'.format(str(channel)), 4, gain[level][2])



class Data(object):
    def __init__(self, config):
        # TODO: create a method to create a filename with date_increasing number
        self.channel = False
        self.data = False
        self.loff_p = True
        self.loff_n = True
        self.config = config
        #self.timestamp = datetime.datetime.now().strftime("%H:%M:%S.%f")
        self.timestamp = datetime.datetime.today()


    def set_channel(self, channel): self.channel = channel
    def set_data(self, data): self.data = data
    def set_loff_n(self, state): self.loff_n = state
    def set_loff_p(self, state): self.loff_p = state
    def get_channel(self): return self.channel
    def get_data(self): return self.data
    def get_timestamp(self): return self.timestamp
    def get_loff_p(self): return self.loff_p
    def get_loff_n(self): return self.loff_n


    def create_file(self):
        """ Create a file if it doesn't exist """
        try:
            with open(self.config.get('log', 'path')) as f: pass
        except IOError as e:
            try:
                FILE = open(self.config.get('log', 'path'), 'w')
                FILE.close()
            except IOError as e:
                log.error('WARNING ... Couldn\'t create file \'%s\''%self.write_path)
                return False
        return True


    def write(self):
        """ Write data to file """
        if self.create_file():
            try:
                FILE = open(self.config.get('log', 'path'), 'a')
                #FILE.write("{0}|{1}|{2}\n".format(self.get_timestamp(), \
                #                                  self.get_channel(), \
                #                                  self.get_data()))
                FILE.write("{0}|{1}\n".format( self.get_channel(), \
                                                  self.get_data()))
                FILE.close()
            except:
                log.error('Failed to write to file')


    def display(self):
        log.info("{0} {1} {2}".format(self.get_timestamp(), self.get_channel(), self.get_data()))



class DataList(object):
    def __init__(self):
        self.data = []


    def add_data(self, data): self.data.append(data)


    def get_last_items(self, channel, last_item=False, amount=False):
        # Get the newest items since the last_item object
        
        # Make a copy to work with, there could occur changes while running this method
        data_list = self.get_data_list(channel)[:]

        # When first run, return all the data received so far
        if not last_item:
            return data_list

        return_list = []

        # Reverse cycle through list_date, searching for last_item and adding all the
        # found objects to return_list on the way
        for data in reversed(data_list):
            if data == last_item:
                return list(reversed(return_list))

            return_list.append(data)

        log.error('Could not find last_item: {0}'.format(last_item))
        return False


    def get_data_list(self, channel):
        return_list = []
        data_tmp = self.data[:]
        for data in data_tmp:
            if int(data.get_channel()) == int(channel):
                return_list.append(data)

        return return_list



class Socket(object):
    def __init__(self, host, port):
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            log.info('Client socket created')
        except socket.error:
            log.error('Failed to create client socket')
            sys.exit()
        #self.socket = socket.socket()
        #self.socket.settimeout(20)
        try:
            self.socket.connect((host, port))
            log.info('Connected to server')
        except socket.error:
            log.error('Failed to connect to server')
            sys.exit()


    def send(self, data, prefix=True):
        # TODO check if connection is still alive
        if prefix:
            data = str(len(data)).rjust(3, '0') + data

        data_bytes = data.encode()

        try:
            self.socket.sendall(data_bytes)
            log.info('<<< {0}'.format(data))
            return True
        except:
            log.error('Failed to send data')
            return False


    def receive(self, bits):
        # TODO check if connection is still alive
        try:
            data = self.socket.recv(int(bits)).decode('utf-8')
            return self.sanitize(data)
        except:
            log.error('Failed to receive data')
        return False


    def sanitize(self, data):
        return data.strip('\n')


    def close(self):
        self.socket.close()
        


class PlotThread(StoppableThread):
    def __init__(self):
        StoppableThread.__init__(self)


    def setup(self):
        self.fig = plt.figure()
        self.ax1 = self.fig.add_subplot(1,1,1)


    def animate(self):
        xar = []
        yar = []

        for data in datalist.get_data_list():
            xar.append(data.get_data())
            yar.append(data.get_timestamp())
        self.ax1.clear()
        self.ax1.plot(xar,yar)


    def plot(self):
        self.setup()
        ani = animation.FuncAnimation(self.fig, self.animate, interval=1000)
        plt.show()
        print('lkjj')


    def run(self):
        print('lkjj')
        self.plot()
        while True:
            pass



class EEG(object):
    def __init__(self, config):
        self.config = config
        self.ads1299 = ADS1299()


    def get_file(self, filename):
        """ Get contents of a file and put every line in a list"""
        contents = []
        try:
            f = open(filename, 'r')
        except IOError as e:
            log.error('No config file found at: {0}'.format(filename))
            return False

        for line in f:
            if line:
                contents.append(line)
        f.close()

        if contents:
            return contents
        return False


    def start_threads(self):
        self.running_threads = []
        self.running_threads.append(QtThread(self.config).start())


    def stop_threads(self):
        for thread in self.running_threads:
            thread.stop()


    def test(self, var):
        try:
            int(var)
            return True
        except:
            return False


    def get_data(self):
        start_time = self.get_timestamp()
        total_frames = 0

        while True:
            # TODO Some of the data is corrupted
            # Receive length of data first
            skipped = 0
            while True:
                length = self.socket.receive(4)
                if length[0] == '#':
                    length = length[1:]
                    break
                skipped += 1
            if self.test(length):
                # then get the full frame 
                data = self.socket.receive(length)
                if data:
                    if self.add_data(data):
                        total_frames += 1
                else:
                    log.error('Error getting data, no data')
            else:
                log.error('Error getting data, length is corrupted: {0}'.format(length))

            # If run-time has reached, send the STOP command to the server
            if start_time + int(self.config.get('general', 'run-time')) <= self.get_timestamp():
                log.info('Run time reached')
                self.socket.send('STOP')

                log.info("Total frames: {0}".format(total_frames))
                log.info("Total time (s): {0}".format(self.get_timestamp() - start_time))
                log.info("FPS: {0}".format(total_frames / (self.get_timestamp() - start_time)))
                log.info("Skipped chars: {0}".format(skipped))

                # TODO: receive total frames sent from server and calculate dropped packages
                # TODO: Packet timing is important since we want to do spectrum analysis
                return True

        log.error('An error occured while transfer')
        return False


    def get_timestamp(self):
        return int(strftime("%d%H%M%S"))


    def add_data(self, rd):
        # Create data objects and add to datalist object
        rd = rd.split(',')
        if len(rd) != 11:
            log.error('Data is corrupted!: {0}'.format(','.join(rd)))
            return False

        channel = 0
        # Skip the status bits start at byte 4
        for d in rd[3:11]:
            channel += 1
            if self.config.get('channel'+ str(channel), 'state') == 'on':
                if d == 0:
                    log.error('Data is 0')
                    return False
                data = Data(self.config)
                data.set_channel(channel)
                data.set_data(d)
                datalist.add_data(data)
        return True


    def send_settings(self):
        for reg in self.ads1299.get_all_regs():
            self.socket.send('WREG,{0},{1}'.format(reg[0], reg[1]))




    def set_srb1(self, state=True):
        if state:
            self.config.set('srb1', 'state', 'ground')
            self.ads1299.set_srb1()
            return
        else:
            self.config.set('srb1', 'state', 'disconnected')
            self.ads1299.set_srb1(state=False)
            return


    def set_ref(self, state=True):
        if state:
            self.config.set('general', 'reference', 'internal')
            self.ads1299.set_internal_ref()
            return
        else:
            self.config.set('general', 'internal', 'external')
            self.ads1299.set_internal_ref(state=False)
            return


    def set_channel(self, channel, state=True):
        if state:
            log.info('Channel{0} is on'.format(channel))
            self.config.set('channel' + str(channel), 'state', 'on')
            self.ads1299.set_channel(channel)
        else:
            log.info('Channel{0} is off'.format(channel))
            self.config.set('channel' + str(channel), 'state', 'off')
            self.ads1299.set_channel(channel, state=False)


    def set_gain(self, channel, level):
        log.info('Gain on Channel{0} is set to: {1}'.format(channel, level))
        self.config.set('channel' + str(channel), 'gain', level)
        self.ads1299.set_gain(channel, level)


    def set_gain_old(self, level):
        level = level.split(',')
        level = [ int(x) for x in level ]
        if len(level) == 2:
            self.config.set('channel' + str(level[0]), 'gain', level[1])
        elif len(level) == 1:
            for channel in range(1, 8+1):
                self.config.set('channel' + str(channel), 'gain', level[0])


    def set_channel_old(self, channels):
        # Set channel in Config() and ADS1299()
        channels = channels.split(',')
        channels = [ int(x) for x in channels ]

        for channel in range(1, 8+1):
            if channel in channels:
                self.config.set('channel' + str(channel), 'state', 'on')
            else:
                self.config.set('channel' + str(channel), 'state', 'off')


    def usage(self):
        print("PYEEG")
        print("OPTIONS:")
        print("  --noise-check")
        print("  --test-signal")
        print("  --plot")
        print("  --start")
        print("  --run-time=<seconds>")
        print("  --channels=1,2,3,4,5,6,7,8")
        print("  --gain=<channel, level> or <level (for all channels)>")
        print("      level = 1,2,4,6,8,12,24")

        print("  --shutdown")


    def set_config_defaults(self):
        self.config.set('server', 'address', 'alarmpi')
        self.config.set('server', 'port', '8888')
        self.config.set('general', 'length-size', '3')
        self.config.set('general', 'run-time', '60')
        self.config.set('general', 'reference', 'internal')
        self.config.set('channel1', 'state', 'on')
        self.config.set('channel2', 'state', 'on')
        self.config.set('channel3', 'state', 'on')
        self.config.set('channel4', 'state', 'on')
        self.config.set('channel5', 'state', 'on')
        self.config.set('channel6', 'state', 'on')
        self.config.set('channel7', 'state', 'on')
        self.config.set('channel8', 'state', 'on')
        self.config.set('channel1', 'gain', '24')
        self.config.set('channel2', 'gain', '24')
        self.config.set('channel3', 'gain', '24')
        self.config.set('channel4', 'gain', '24')
        self.config.set('channel5', 'gain', '24')
        self.config.set('channel6', 'gain', '24')
        self.config.set('channel7', 'gain', '24')
        self.config.set('channel8', 'gain', '24')
        self.config.set('srb1',     'state','ground')
        self.config.set('log', 'path', '/home/eco/eeg.txt')


    def handle_arg(self):
        if len(sys.argv) < 2 or "--help" in sys.argv:
            return self.usage()

        # Setting config values
        for arg in sys.argv:

            if len(arg.split('=')) == 2:
                key = arg.split('=')[0][2:]
                value = arg.split('=')[1]

                if '--run-time=' in arg:
                    self.config.set('general', key, value)

                elif '--address=' in arg:
                    self.config.set('server', key, value)

                elif '--port=' in arg:
                    self.config.set('server', key, value)

                elif '--channels=' in arg:
                    self.set_channel(value)

                elif '--gain=' in arg:
                    self.set_gain(value)

        # Commands
        for arg in sys.argv:
            if "--plot" in arg:
                self.start_threads()

            if "--start" in arg:
                # NOTE is not receiving on the c side!!
                self.send_channel_config()
                self.socket.send('START')
                self.get_data()

            elif "--noise-check" in arg:
                self.socket.send('NOISECHECK')
                self.get_data()

            elif "--test-signal" in arg:
                self.socket.send('TESTSIGNAL')
                self.get_data()

            elif "--shutdown" in arg:
                self.socket.send('SHUTDOWN')

        return False


    def connect(self):
        # Create socket
        self.socket = Socket(self.config.get('server', 'address'), self.config.get('server', 'port'))


    def disconnect(self):
        # Close
        log.info('Connection to server is closed')
        self.socket.close()


        
    def run(self):
        self.set_config_defaults()
        self.connect_to_server()

        # Set some defaults
        self.set_srb1()
        self.send_srb1()
        self.set_ref()
        self.send_ref()

        self.handle_arg()
        self.disconnect()

log = Log()


if __name__ == "__main__":
    config = Config()
    datalist = DataList()
    ads1299 = ADS1299()
    log = Log()
    log.color('>>>', 'green')
    log.color('<<<', 'blue')
    log.color('###', 'red')
    log.color('---', 'blue')

    app = EEG(config)
    app.run()
