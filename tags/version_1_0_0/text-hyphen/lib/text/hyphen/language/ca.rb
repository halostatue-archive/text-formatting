# Hyphenation patterns for Text::Hyphen in Ruby: Catalan
#   Converted from the TeX hyphenation/cahyph.tex file version 1.11, by
#   Gon�al Badenes and Francina Turon, copyright 1991 - 2003.
#
# The original copyright holds and is reproduced in the source to this file.
# The Ruby version of these patterns are copyright 2004 Austin Ziegler and
# are available under an MIT license. See LICENCE for more information.
#
#--
# Hyphenation patterns for Catalan.
# This is version 1.11
# Compiled by Gon�al Badenes and Francina Turon,
#       December 1991-January 1995.
#
# Copyright (C) 1991-2003 Gon�al Badenes
#
# -----------------------------------------------------------------
# IMPORTANT NOTICE:
#
# This program can be redistributed and/or modified under the terms of the
# LaTeX Project Public License Distributed from CTAN archives in directory
# macros/latex/base/lppl.txt; either version 1 of the License, or any later
# version.
# -----------------------------------------------------------------
#
### ====================================================================
###  @TeX-hyphen-file{
###     author          = "Gon�al Badenes",
###     version         = "1.11",
###     date            = "15 July 2003",
###     time            = "15:08:12 CET",
###     filename        = "cahyph.tex",
###     email           = "g.badenes@ieee.org",
###     codetable       = "ISO/ASCII",
###     keywords        = "TeX, hyphen, catalan",
###     supported       = "yes",
###     abstract        = "Catalan hyphenation patterns",
###     docstring       = "This file contains the hyphenation patterns
###                        for the catalan language",
###  }
### ====================================================================
#
# NOTICE: Version 1.11 is identical to version 1.10 (issued on January 17,
#         1995) except for the updated copyright notice above.
#
# The macros used were created for ghyph31.tex by Bernd Raichle (see the
# German hyphenation pattern files for further details)
#
# This patterns have been created using standard, conservative hyphenation
# rules for catalan. The results have refined running them through patgen.
# In that way, the number of hits has been increased.
#
# These rules produce no wrong patterns (Results checked against the
# ``Diccionari Ortogr�fic i de Pron�ncia'', Enciclop�dia Catalana. The
# percentage of valid hyphen misses is lower than 1%
#
# Some of the patterns below represent combinations that never happen in
# Catalan. We have tried to keep them to a minimum.
#
# *** IMPORTANT ***
# \lefthyphenmin and \righthyphenmin should be set to 2 and 2 respectively.
# If you set them below these values incorrect breaks will happen (specially
# at the beginning of foreign words and words which begin with some
# prefixes).
# *** IMPORTANT ***
#
# Please report any problem you might have to the authors!!!
#++
require 'text/hyphen/language'

Text::Hyphen::Language::CA = Text::Hyphen::Language.new do |lang|
  lang.patterns <<-PATTERNS
  % Attach vowel groups to left consonant
1ba 1be 1bi 1bo 1bu 1ca 1ce 1ci 1co 1cu 1da 1de 1di 1do 3du 1fa 1fe 1fi 1fo
1fu 1ga 1ge 1gi 1go 1gu 1ha 1he 1hi 1ho 1hu 1ja 1je 1ji 1jo 1ju 1la 1le 1li
1lo 1lu 1ma 1me 1mi 1mo 1mu 1na 1ne 3ni 1no 1nu 1pa 3pe 3pi 3po 1pu 1qu 1ra
1re 1ri 1ro 1ru 1sa 1se 1si 1so 1su 1ta 1te 1ti 1to 1tu 1va 1ve 1vi 1vo 1vu
1xa 1xe 1xi 1xo 1xu 1za 1ze 1zi 1zo 1zu 1b� 1b� 1b� 1b� 1b� 1b� 1b� 1c� 1c�
1c� 1c� 1c� 1c� 1c� 1�o 1�a 1�u 1�� 1�� 1�� 1�� 1d� 1d� 1d� 1d� 1d� 1d� 1d�
1f� 1f� 1f� 1f� 1f� 1f� 1f� 1g� 1g� 1g� 1g� 1g� 1g� 1g� 1g� 1h� 1h� 1h� 1h�
1h� 1h� 1h� 1j� 1j� 1j� 1j� 1j� 1j� 1j� 1l� 1l� 1l� 1l� 1l� 1l� 1l� 1m� 1m�
1m� 1m� 1m� 1m� 1m� 1n� 1n� 1n� 1n� 1n� 1n� 1n� 1p� 1p� 1p� 1p� 1p� 1p� 1p�
1q� 1r� 1r� 1r� 1r� 1r� 1r� 1r� 1s� 1s� 1s� 1s� 1s� 1s� 1s� 1t� 1t� 1t� 1t�
1t� 1t� 1t� 1v� 1v� 1v� 1v� 1v� 1v� 1v� 1x� 1x� 1x� 1x� 1x� 1x� 1x� 1z� 1z�
1z� 1z� 1z� 1z� 1z�

% Build legal consonant groups, leave other consonants bound to
% the previous group. This overrides part of the previous pattern
% group.
3l2la 1l2le 1l2li 3l2lo 1l2lu 1b2la 1b2le 1b2li 1b2lo 1b2lu 1b2ra 1b2re
1b2ri 1b2ro 1b2ru 1c2la 1c2le 1c2li 1c2lo 1c2lu 1c2ra 1c2re 1c2ri 1c2ro
1c2ru 1d2ra 1d2re 1d2ri 1d2ro 1d2ru 1f2la 1f2le 1f2li 1f2lo 1f2lu 1f2ra
1f2re 1f2ri 1f2ro 1f2ru 1g2la 1g2le 1g2li 1g2lo 1g2lu 1g2ra 1g2re 1g2ri
1g2ro 1g2ru 1p2la 1p2le 1p2li 1p2lo 1p2lu 1p2ra 1p2re 1p2ri 1p2ro 1p2ru
1t2ra 1t2re 1t2ri 1t2ro 1t2ru 1n2ya 1n2ye 1n2yi 1n2yo 1n2yu 1l2l� 1l2l�
1l2l� 1l2l� 1l2l� 1l2l� 1l2l� 1b2l� 1b2l� 1b2l� 1b2l� 1b2l� 1b2l� 1b2l�
1b2r� 1b2r� 1b2r� 1b2r� 1b2r� 1b2r� 1b2r� 1c2l� 1c2l� 1c2l� 1c2l� 1c2l�
1c2l� 1c2l� 1c2r� 1c2r� 1c2r� 1c2r� 1c2r� 1c2r� 1c2r� 1d2r� 1d2r� 1d2r�
1d2r� 1d2r� 1d2r� 1d2r� 1f2l� 1f2l� 1f2l� 1f2l� 1f2l� 1f2l� 1f2l� 1f2r�
1f2r� 1f2r� 1f2r� 1f2r� 1f2r� 1f2r� 1g2l� 1g2l� 1g2l� 1g2l� 1g2l� 1g2l�
1g2l� 1g2r� 1g2r� 1g2r� 1g2r� 1g2r� 1g2r� 1g2r� 1p2l� 1p2l� 1p2l� 1p2l�
1p2l� 1p2l� 1p2l� 1p2r� 1p2r� 1p2r� 1p2r� 1p2r� 1p2r� 1p2r� 1t2r� 1t2r�
1t2r� 1t2r� 1t2r� 1t2r� 1t2r� 1n2y� 1n2y� 1n2y� 1n2y� 1n2y� 1n2y� 1n2y�

  % Vowels are kept together by the defaults. We break here diphthongs and
  % the like.
a1a a1e a1o e1a e1e e1o i1a i1e i1o o1a o1e o1o u1a u1e u1o a1� a1� a1� a1�
a1� a1� a1� a1� a1� e1� e1� e1� e1� e1� e1� e1� e1� e1� i1� i1� i1� i1� i1�
i1� i1� i1� i1� o1� o1� o1� o1� o1� o1� o1� o1� o1� u1� u1� u1� u1� u1� u1�
u1� u1� u1� �1a �1e �1o �1� �1� �1a �1e �1o �1� �1� �1a �1e �1o �1� �1� �1a
�1e �1o �1� �1� �1a �1e �1o �1� �1� �1a �1e �1o �1� �1� �1a �1e �1o �1� �1�
�1a �1e �1o �1� �1� �1� �1� �1� �1� �1� �1i �1a �1e �1o �1� �1� �1� �1� �1�
�1� �1�

  % We consider here i and u as semiconsonants
a1i2a a1i2e a1i2o a1i2u a1u2a a1u2e a1u2i a1u2o a1u2u e1i2a e1i2e e1i2o
e1i2u e1u2a e1u2e e1u2i e1u2o e1u2u i1i2a i1i2e i1i2o i1i2u i1u2a i1u2e
i1u2i i1u2o i1u2u o1i2a o1i2e o1i2o o1i2u o1u2a o1u2e o1u2o o1u2i o1u2u
u1i2a u1i2e u1i2o u1i2u u1u2a u1u2e u1u2i u1u2o u1u2u a1i2� a1i2� a1i2�
a1i2� a1i2� a1i2� a1i2� a1u2� a1u2� a1u2� a1u2� a1u2� a1u2� a1u2� e1i2�
e1i2� e1i2� e1i2� e1i2� e1i2� e1i2� e1u2� e1u2� e1u2� e1u2� e1u2� e1u2�
e1u2� i1i2� i1i2� i1i2� i1i2� i1i2� i1i2� i1i2� i1u2� i1u2� i1u2� i1u2�
i1u2� i1u2� i1u2� o1i2� o1i2� o1i2� o1i2� o1i2� o1i2� o1i2� o1u2� o1u2�
o1u2� o1u2� o1u2� o1u2� o1u2� u1i2� u1i2� u1i2� u1i2� u1i2� u1i2� u1i2�
u1u2� u1u2� u1u2� u1u2� u1u2� u1u2� u1u2� �1i2a �1i2e �1i2o �1i2u �1u2a
�1u2e �1u2o �1u2i �1u2u �1i2a �1i2e �1i2o �1i2u �1u2a �1u2e �1u2o �1u2i
�1u2u �1i2a �1i2e �1i2o �1i2u �1u2a �1u2e �1u2o �1u2i �1u2u �1i2a �1i2e
�1i2o �1i2u �1u2a �1u2e �1u2o �1u2i �1u2u �1i2a �1i2e �1i2o �1i2u �1u2a
�1u2e �1u2o �1u2i �1u2u �1i2a �1i2e �1i2o �1i2u �1u2a �1u2e �1u2o �1u2i
�1u2u �1i2a �1i2e �1i2o �1i2u �1u2a �1u2e �1u2o �1u2i �1u2u �1i2a �1i2e
�1i2o �1i2� �1i2� �1i2� �1i2� �1i2� �1i2� �1i2� �1i2u �1u2a �1u2e �1u2o
�1u2� �1u2� �1u2� �1u2� �1u2� �1u2� �1u2� �1u2i �1u2u �1i2a �1i2e �1i2o
�1i2� �1i2� �1i2� �1i2� �1i2� �1i2� �1i2� �1i2u �1u2a �1u2e �1u2o �1u2�
�1u2� �1u2� �1u2� �1u2� �1u2� �1u2� �1u2i �1u2u

  % Semiconsonants at the beginning of word
.hi2a .hi2e .hi2o .hi2u .hu2a .hu2e .hu2i .hu2o .i2� .i2� .u2� .u2� .hi2�
.hi2� .hi2� .hi2� .hi2� .hi2� .hu2� .hu2� .hu2� .hu2� .hu2� .hu2�

  % And now the crescent diphtongs
gu2a gu2e gu2i gu2o qu2a qu2e qu2i qu2o gu2� gu2� gu2� gu2� gu2� gu2� qu2�
qu2� qu2� qu2� qu2� qu2� g�2e g�2� g�2� g�2� g�2i q�2e q�2� q�2� q�2� q�2i

  % We add here some exceptions to the rules for diaeresis
a1isme. e1isme. i1isme. o1isme. u1isme. a1ista. e1ista. i1ista. o1ista.
u1ista. a1um. e1um. i1um. o1um. u1um.

  % disallow hyphenation on possible prefixes
.antihi2 .be2n .be2s .bi2s .ca2p .ce2l .cla2r .co2ll .co2n .co2r .de2s .di2s
.en3a .hipe2r .hiperm2n .in3ac .in3ad .in3ap .in3es .in3o .inte2r .ma2l
.mal1t2hus .pa2n .pe2r .pe3ri .pos2t .psa2l .rebe2s .re2d .su2b .sub3o
.subde2s .supe2r .tran2s

  % Avoid hyphenation on some intra-word groups
g2no p2si p2se p2neu g2n� p2s�

  % Avoid wrong hyphenation on some foreign-origin words
.ch2 .th2 ein1s2tein ru1t2herford ni2etz1sc2he

  % Add some good patterns found by patgen
3exp 3nef 3nei 3pr 3ser a3ne a3ri bi3se des3ag des3ar des3av des3enc e3ism
e3le e3rio e3ris es3aco es3af es3ap es3arr es3as es3int ig3n in3ex n3si o3ro
qui3e s3emp s3esp sub3a ui3et o3gn�
  PATTERNS

  lang.exceptions <<-EXCEPTIONS
% Finally, add exception list
cu-rie cu-ries gei-sha gei-shes goua-che goua-ches hip-py hip-pies hob-by
hob-bies jeep jeeps joule joules klee-nex klee-nexs lar-ghet-ti lar-ghet-to
lied lieder nos-al-tres % me-nhir me-nhirs
ro-yal-ties ro-yal-ty vos-al-tres whis-ky whis-kies
  EXCEPTIONS
end
Text::Hyphen::Language::CAT = Text::Hyphen::Language::CA
