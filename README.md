# Projeto ULA CPLD - Clone da ULA do TK90X/TK95.

Este projeto se destina a substituir um componente feito sob medida para o microcomputador de 8 bits modelo TK90X e TK95, fabricado pela empresa brasileira Microdigital na década de 1980. O TK90X/TK95 é um clone do ZX Spectrum fabricado pela empresa inglesa Sinclair Research.

# Copyright

Copyright Fábio Belavenuto 2012.
Copyright Victor Trucco 2012.

# Licença

This documentation describes Open Hardware and is licensed under the CERN OHL v. 1.1.
You may redistribute and modify this documentation under the terms of the
CERN OHL v.1.1. (http://ohwr.org/cernohl). This documentation is distributed
WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
Please see the CERN OHL v.1.1 for applicable conditions

# Detalhes

Todo este trabalho foi baseado no trabalho do Chris Smith [1] e feito em conjunto pelos autores do projeto. Agradecimentos ao pessoal das listas de discussão brasileiras "ClubedoTK" [2] e "TK90X" [3] que incentivaram e ajudaram no desenvolvimento deste projeto.

No site [4] há um pequeno diário criado pelo Victor Trucco descrevendo os passos durante o desenvolvimento do projeto.

O projeto tem duas revisões, rev1 e rev2, cada uma delas em uma pasta separada. Em cada revisão existem uma pasta com o design da PCB, uma pasta com os aqruivos de fabricação Gerber e uma pasta com o projeto do código-fonte do CPLD. A versão do software utilizado para o design da PCB foi o Cadsoft Eagle e o software utilizado para o design do CPLD foi o Altera Quartus versão 10.1sp1.
  
Na pasta "VHDL Version" há uma versão do código do CPLD toda escrita em VHDL, tanto para CPLDs da Altera e CPLDs da Xilinx. Este código não foi usado no CPLD da ULA final.

Para a revisão 1, o arquivo [Pinout jumpers.jpg] "rev1/Pinout jumpers.jpg" mostra a pinagem dos jumpers e saída RGB contidas na PCB. Para a revisão 2 o mesmo pinout pode ser utilizado, porém a seleção do tipo de sincronismo é feita por jumpers de solda.

O produto final é uma placa pequena feita para ser inserida diretamente no soquete do circuito integrado original, substituindo assim o componente defeituoso, com a vantagem de ter uma saída RGB analógica em 15KHz para ser usado diretamente em monitores compatíveis.

A temporização deste projeto chega a 99% de fidelidade ao componente original.

# Montagem

Para a montagem da PCB, acesse [este](https://fbelavenuto.github.io/pages/ULA-rev1-ibom.html) link para BOM interativo da revisão 1 e [este](https://fbelavenuto.github.io/pages/ULA-rev2-ibom.html) para a revisão 2.

Solde os componentes SMD, consiga uma barra de terminais torneado de 80 pinos, corte-a no meio para os dois lados de 40 pinos. O CPLD ocupa o espaço de quatro pinos da barra de terminais torneada de cada lado, então é necessário cortar os 4 pinos centrais de cada barra para fazer uma soldagem em SMD nestes pontos.

Coloque a barra no lugar para descobrir quais os pinos devem ser cortados, corte com um alicate de corte fino para deixar rente à PCB. Utilize um soquete torneado de 40 pinos e plugue as barras no soquete, para uma soldagem alinhada. Coloque a PCB em cima da barra e encaixe os pinos não cortados nos seus respectivos furos e solde-os. Para soldar os 8 pinos cortados (4 de cada lado) coloque a ponta de ferro em um lado para aquecer a PCB e a barra de pinos ao mesmo tempo e coloque o estanho pelo outro lado. Confira com uma lente se a solda foi bem sucedida.

Se for utilizar a saída RGB 15KHz solde uma barra de pinos 90 graus na PCB, e na revisão 2 solde o jumper de solda do tipo de sincronismo. É possível escolher qual tipo de sincronismo irá para o monitor, separado ou composto. Dependendo do monitor um tipo poderá ser melhor que o outro, então pode ser necessário testar os dois tipos, porém a opção de sincronismo separado tem mais compatibilidade com os monitores.

Na pasta [Fotos](rev1/Fotos/) há algumas fotos do primeiro protótipo construido.

# Programação do CPLD

Para programar o CPLD é necessário um dispositivo USB Blaster específico para os CPLDs da Altera. Na PCB rev1 os pontos de contato dos sinais de programação estão espalhados pela PCB, sendo necessário a construção de uma "cama de pregos" ou a soldagem de fios nos pontos. Para a rev2 os sinais estão dispostos em um conector 1x6. O nome dos sinais estão no silkscreen da PCB. É necessário utilziar uma fonte externa de 5V e jogar 5V no pino VCC do USB Blaster, pois este não alimenta o dispositivo mas detecta se ele está alimentado.

Abra o projeto no software Quartus e vá até o programador. Alimente a PCB e o USB Blaster e clique em "Program". Caso haja falha neste passo cheque as conexões e cheque se está indo os 5V para o USB Blaster. O arquivo necessário para programar se chama "ULA.pof".

# Uso

É altamente recomendável a troca do soquete da ULA na PCB do TK90X/95 por um soquete torneado, porém é possível utilizar o original. Plugue com cuidado a PCB da ULA no soquete do TK, vá pressionando devagar para não entortar nenhum pino. Se tudo ocorrer bem é só ligar o micro e curtir a sua nova ULA.

Se for utilizar a saída RGB 15KHz construa um cabo com um conector DE-15 para ligar nos pinos de saída RGB conforme descrito [nesta](rev1/Pinout%20jumpers.jpg) imagem.

# Links

[1] http://www.zxdesign.info/thebeginning.shtml
[2] http://br.groups.yahoo.com/group/ClubedoTK/
[3] http://br.groups.yahoo.com/group/TK90X/
[4] http://www.victortrucco.com/TK/ULATKCPLD/ULATKCPLD.asp
