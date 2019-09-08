# Projeto ULA CPLD - Clone da ULA do TK90X/TK95.

Copyright F�bio Belavenuto 2012.
Copyright Victor Trucco 2012.

This documentation describes Open Hardware and is licensed under the CERN OHL v. 1.1.
You may redistribute and modify this documentation under the terms of the
CERN OHL v.1.1. (http://ohwr.org/cernohl). This documentation is distributed
WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
Please see the CERN OHL v.1.1 for applicable conditions


  Este projeto se destina a substituir um componente feito sob medida para o
microcomputador de 8 bits modelo TK90X e TK95, fabricado pela empresa
brasileira Microdigital na d�cada de 1980. O TK90X/TK95 � um clone do ZX
Spectrum fabricado pela empresa inglesa Sinclair Research.

  Todo este trabalho foi baseado no trabalho do Chris Smith [1] e feito em
conjunto pelos autores do projeto. Agradecimentos ao pessoal das listas de
discuss�o brasileiras "ClubedoTK" [2] e "TK90X" [3] que incentivaram e ajudaram
no desenvolvimento deste projeto.

  No site [4] h� um pequeno di�rio criado pelo Victor Trucco descrevendo os passos
durante o desenvolvimento do projeto.

  Junto a este "leia-me" h� duas pastas, uma chamada "Eagle layout" contendo o esquema
e o layout da PCB no formato do software Cadsoft Eagle 6.3.0, e outra pasta chamada
"Quartus Project" contendo os arquivos do c�digo do CPLD no formato do software Altera
Quartus 10.1sp1. H� tamb�m uma pasta chamada "Fotos" com imagens do produto final.

  No arquivo de imagem "Pinout jumpers.jpg" h� informa��o da pinagem dos jumpers e
sa�da RGB contidas na pcb.

  O produto final � uma placa pequena feita para ser inserida diretamente no soquete
do circuito integrado original, substituindo assim o componente defeituoso, com a 
vantagem de ter uma sa�da RGB anal�gica em 15KHz para ser usado diretamente em
monitores compat�veis.

  A temporiza��o deste projeto chega a 99% de fidelidade ao componente original.

  Os contatos dos autores est�o no arquivo texto "PRODUCT.txt".


[1] http://www.zxdesign.info/thebeginning.shtml
[2] http://br.groups.yahoo.com/group/ClubedoTK/
[3] http://br.groups.yahoo.com/group/TK90X/
[4] http://www.victortrucco.com/TK/ULATKCPLD/ULATKCPLD.asp