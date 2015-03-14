# Matlab model #

  1. ~~Improve preamble detection code. Right now it doesn't work if some phase shift after FFT is present. My guess is that this is caused by SFO, so that's what we need to solve, but I may be wrong and solution is elsewhere.~~ **Revision: 5414e88fdfcb (needs more testing)**
  1. Carrier Frequency Offset (CFO) estimation and compensation (rough and fine-grained). **Revision: 5414e88fdfcb (disabled right now due to some bug)** <a href='Hidden comment: 
.
В настоящий момент система компенсации CFO отсутствует в принципе. Роль этой системы выполняют channel_estimator и equalizer. В принципе возможна реализация этой системы двумя способами
а) Измерить значение CFO по преамбуле и сдвигать спектр сигнала перед FFT на измеренную величину. Я так пытался
делать и функция  find_preamble возвращает значение CFO и вроде это значение получается правильное, но почему-то
когда я пытался компенсировать это CFO демодуляция становилась хуже. Такое впечатления что какая-то систематическая
ошибка тут получается а может просто ошибка в программе.
b) Можно получать информацию об CFO из channel estimatora.
Наверное оптимальным будет использовать варианты a и b совместно.
.
'></a>
  1. Symbol Frequency Offset (SFO, aka sampling frequency offset) estimation and compensation.<a href='Hidden comment: 
.
Мне кажется что компенсация SFO вообще не нужна. Грубо говоря длительность пакета у нас 5 ms. Частота сэмплирования 11 МГц, точность установки частоты АЦП 1E-4 тогда за время пакета граница символа сдвинется на 5.5 отсчетов (0.005 * 11E6 * 1E-4), что ничтожно мало по сравнения с длительностью защитного интервала.
.
С другой стороны, промышленные реализации компенсируют SFO. Мы точно знаем, что это делают в Sandbridge.
.
'></a>
  1. Better channel estimation and compensation code. **Revision: 5414e88fdfcb (partially, needs more work)** <a href='Hidden comment: 
.
Однозначно нуждается в доработке. Но нужен симулятор канала.
По имеющимся векторам достаточно хорошо все работает :).
.
'></a>
  1. Clean up code and make it closer to a real C code.
  1. Port essential parts of the model to fixed point.
  1. ~~Better repetition decoding to improve reception quality.~~ **Revision: 5414e88fdfcb**
  1. ~~Turbo decoder implementation to enable DL-MAP decoding.~~ **Revision: d9e0522bd477**
  1. Own implementation of soft-bit demodulation and SISO decoding which we can port to C code. We should look for existing open-source C code for this and bring it into the Matlab model too, so our model and the code are bit-exact.
  1. RSSI and CINR calculation, as per `8.4.12 Channel quality measurements`.

# FPGA #

These todo items remains from our original effort to implement everything in FPGA. They're left here in a case someone want to continue this effort.

  1. Integration with USRP N210 to output signal after synchronization and FFT instead of raw I/Q data.
  1. Channel equalization at least for DL-PUSC pilot structure. We may also take into account preamble pilots for better estimation. Altera's [AN434 application note](http://www.altera.com/literature/an/an434.pdf) has a nice introduction into the topic from FPGA implementation point of view, BUT it describes UL tiled pilots which is quite different from DL-PUSC. [This paper](http://www.hindawi.com/journals/jcsnc/2010/806279.html) looks like a good introduction into DL-PUSC channel estimation and tracking.
  1. Frequency offset and phase offset compensation.
  1. QPSK hard demodulation, then soft demodulation. _/Euripedes Rocha Filho/_
  1. CC and CTC decoding hard demodulation, then soft demodulation.
  1. Repetition Viterbi decoding (would be really nice to improve frame detection).

# Channel modeling #

  1. ~~IMTAphy installation and connecting it to Matlab - 2 days (24.04.2011)~~. **Done**
  1. Study IMTAphy - 1-1,5 Week (approximately 09.05.2011).
  1. Creating a function to apply channel model to an input signal - 1,5 weeks.

# Wireshark integration #

  1. ~~Integrate Wireshark WiMAX Protocol dissectors with GSMTAP packet.~~ **Revision: e1cf9497e644**
  1. ~~Create program sending GSMTAP messages with payload in various formats of WiMAX interfaces.~~ **Revision: 	5dd903bc4cbe, 1303ab3b958b**
  1. ~~Test Wireshark WiMAX dissectors on real data and find bugs in dissectors realization.~~ **Done, though this never really ends**
  1. ~~Fix bugs in Wireshark WiMAX dissectors.~~ **Revision: 0d8437d01351, 	c8904e929167, e71e7b11ef21, 19e444f9379e**
  1. Integrate fixes upstream.