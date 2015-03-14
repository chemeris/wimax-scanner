# Introduction #

In this series of articles we will go through the PHY level of Mobile WiMAX aka IEEE 802.16e aka WirelessMAN-OFDMA. We will be looking into a real captured WiMAX data and go from raw I/Q data to the header bits.

We will use Matlab code, checked into the project repository under [matlab](http://code.google.com/p/wimax-scanner/source/browse/#hg%2Fmatlab) directory. Later we should update these articles to include references to the relevant C/C++ code.

**Note**: These articles are wiki and thus are subject to change without prior notice.

# The Standard #

<img src='http://www.wimaxforum.org/sites/wimaxforum.org/themes/custom/wimax_forum/images/branding/logo_small.png' align='left'> <img src='http://upload.wikimedia.org/wikipedia/en/thumb/2/21/IEEE_logo.svg/200px-IEEE_logo.svg.png' align='right'> The standard is widely known by its brand name "Mobile WiMAX", which is actually a profile for a broader specification formally named IEEE Std 802.16-2009. IEEE 802.16-2009 is a 2000 page document which defines several modes of operation (WirelessMAN-SC, WirelessMAN-OFDM and WirelessMAN-OFDMA). We have no references to any use of WirelessMAN-SC. WirelessMAN-OFDM is widely used under the name "Fixed WiMAX". And WirelessMAN-OFDMA is a base for Mobile WiMAX profile, which specifies a subset of it which is mandatory, a subset which is optional to implement, what frequencies to use, etc. WiMAX profiles are specified by a separate organization - <a href='http://www.wimaxforum.org/'>WiMAX Forum</a> (<a href='http://en.wikipedia.org/wiki/WiMAX#WiMAX_Forum'>Wikipedia</a>).<br>
<br>
<b>Useful links</b>:<br>
<ul><li><a href='http://standards.ieee.org/about/get/802/802.16.html'>Full set of 802.16 standards and additions</a>
</li><li><a href='http://standards.ieee.org/getieee802/download/802.16-2009.pdf'>IEEE 802.16-2009 standard itself</a> (pdf, 10.6Mb)<br>
</li><li><a href='http://www.wimaxforum.org/resources/documents/technical/release'>WiMAX PHY profiles and network specifications</a></li></ul>

<h1>Assumptions</h1>

Below we use following reasonable assumptions:<br>
<br>
<ul><li>10MHz bandwidth signal.<br>
</li><li>TDD mode (Time Division Duplex).</li></ul>

<h1>I/Q signal</h1>

<blockquote>According to section "8.4.2.3 Primitive parameters" of the standard, oversampling factor <code>n</code> for 10MHz bandwidth is 28/25, so signal was sampled at 11.2 MSPS.</blockquote>

Lets look at a spectrogram view of three WiMAX frames (red is signal, yellow-green is no signal):<br>
<a href='http://wiki.wimax-scanner.googlecode.com/hg/images/WiMAX-PHY/3frames-big.jpg'><img src='http://wiki.wimax-scanner.googlecode.com/hg/images/WiMAX-PHY/3frames-small.png' /></a>
(click to see higher resolution image)<br>
<br>
<a href='Hidden comment: 
_*TODO: Spectrum picture*_
'></a><br>
<br>
The picture clearly shows <a href='http://en.wikipedia.org/wiki/Orthogonal_frequency-division_multiplexing'>OFDM</a> structure of the signal, where wide channel bandwidth is splited into a large number of narrow sub-cannels. Benefits of OFDM include easier channel equalization and resistence to multipath. Those who are not familiar with OFDM are advise to look into it now. An intuitive OFDM tutorial you may find <a href='http://www.complextoreal.com/chapters/ofdm2.pdf'>here</a>.<br>
<br>
For details about 802.16 OFDMA mode refer to the chapter "8.4.2 OFDMA symbol description, symbol parameters and transmitted signal" of the standard. Important things to note are:<br>
<ul><li>FFT size for 10MHz bandwidth is 1024, so signal has 1024 subcarriers.<br>
</li><li>92 left subcarriers and 91 right subcarriers are zeroed and used as a guard interval between frequency channels.<br>
</li><li>DC subcarrier is always zero.<br>
</li><li>Remaining (1024-92-91-1)=840 subcarriers may carry data or pilots. In the case of 1024-FFT, 120 subcarriers are allocated to pilots and 720 are allocated to dataa. More on this allocation later.</li></ul>

We work with a TDD signal, so both downlink (base station to terminal) and uplink (terminal to base station) data are on the same channel:<br>
<img src='http://wiki.wimax-scanner.googlecode.com/hg/images/WiMAX-PHY/specgram-frame-described.png' />

Structure of TDD frame is described in section "8.4.4.1 TDD frame structure" of the standard and pictured on Figure 222 of the standard. Please note, that standard refers to logical subchannels instead of physical subcarriers there. Relationship between subcarriers and subchannels is a complex 1-to-N maping and is described later.<br>
<br>
<h1>Preamble</h1>

Preamble is clearly seen on previous pictures. Preamble occupies the first OFDM symbol of a frame and has slightly wider banwidth then other parts of a frame. To simplify preamble detection it is also transmitted with higher power. Refer to the chapter "8.4.6.1.1 Preamble" of the standard for details about preamble generation.<br>
<br>
Important facts about the preamble:<br>
<ul><li>Preamble spans 284*3=852 subcarriers for 1024-FFT instead of 840 subcarriers for the rest of the frame. So it has 86 guard subchannels on each side.<br>
</li><li>Preamble consists only of pilots, which are allocated to every 3rd subcarrier.<br>
</li><li>Preamble pilots are modulated with BPSK, as all other pilots.<br>
</li><li>Preamble pilots are allocated to subchannels with numbers (n + 3k), where n may be 0, 1 or 2 and means so called "segment".<br>
</li><li>There are 114 possible preambles (see Table 438 in the standard), each coding some combination of a segment number and an IDCell number.<br>
</li><li>Preamble is fixed for each base station and each base station sector.</li></ul>

<a href='Hidden comment: 
_*TODO: pictures here - preamble after FFT, constellation, I/Q*_
'></a><br>
<br>
When preamble is known, it's easy to find it in a stream with a usual matched filter. But when you don't know which preamble is used, like if device just has been powered up, task is much more tough. Running 114 matched filters simultaneously is too costly, so there are two most popular approaches, to my knowledge:<br>
<ol><li><b>CP and signal level.</b> CP is just a copy of the end of an OFDM symbol, so you can find the start of an OFDM symbol by running a corelator with length of CP, comparing data at time <code>t</code> with data at time <code>t+1024</code> (for 1024-FFT). This way you can find beginning of any OFDM symbol in a frame. Preamble has higher signal level then the rest of the frame, so you just pick OFDM symbol with the highest correlation value.<br>
</li><li><b>Three repetitions.</b> In preamble only every 3rd subcarrier is transmitted, so in time space it looks like three repetitions (not counting CP). This is a rare property and gives pretty high confidence that you've found a preamble.</li></ol>

Both these methods for preamble search don't give you preamble number, they just show you a place where preamble is most likely located. To detect which preamble is used, you correlate received preamble with all 114 defined preambles, either in time or in frequency space (latter works better).<br>
<br>
<h1>Subchannelization</h1>

Mobile WiMAX has a complex mapping of data to physical subcarriers, involving shuffling and permutation on many levels. This mapping is described in sections "8.4.3 OFDMA basic terms definition" and "8.4.6.1.2.1 Symbol structure for PUSC".<br>
<br>
<a href='Hidden comment: 
_*TODO: Describe DL-PUSC*_
'></a><br>
<br>
<h1>Frame header</h1>

Frame header is an informal name, which is not used in the standard. We use it to refer to frame fields whic are essential for further frame decoding, like FCH (Frame Control Header, contains <code>DL_Frame_Prefix</code> data structure), DL-Map (DownLink Map), UL-Map (UpLink Map), DCD (DL channel descriptor) and UCD (UL channel descriptor).<br>
<br>
<h2>FCH</h2>

FCH is an abbreviation for Frame Control Header,and that's the first thing you should decode in a packet. It contains <code>DL_Frame_Prefix</code> data structure which as lenth of 24 bits and provides information required to decode other frame header fields:<br>
<ol><li>Used subchannel bitmap - which subchannel major groups are used to carry data. All real world signals we've seen so far use all major groups.<br>
</li><li>Repetition Coding Indication - number of repetitions used for DL-MAP coding. All real world signals we've seen so far use repetition 4 for DL-MAP.<br>
</li><li>Coding Indication - which coding scheme is used for DL-MAP coding. WiMAX profile specifies only CC and CTC as mandatory to implement, so that's what is most likely to be used here. All real world signal we've seen so far use CTC for DL-MAP coding.<br>
</li><li>DL-Map Length - length of DL-MAP data in slots.</li></ol>

For further details about <code>DL_Frame_Prefix</code> refer to section "8.4.4.4 DL frame prefix" of the standard<br>
<br>
<i><b>to be continued...</b></i>