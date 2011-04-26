#ifndef _WMXTAP_H 
#define _WMXTAP_H 
	 
/* wimaxtap header, pseudo-header in front of the actua/ wimax payload */ 
/* WMXTAP is a generic header format for wimax protocol captures, 
 * it uses UDP port number 4779 and carries 
 * payload in various formats of wimax interfaces. 
 */ 

	#define WMXTAP_TYPE_BURST                0x01 
	
	#define WMXTAP_BURST_UNKNOWN             0x00 
 	#define WMXTAP_BURST_CDMA_CODE           0x01 
	#define WMXTAP_BURST_FCH                 0x02
	#define WMXTAP_BURST_FFB                 0x03 
	#define WMXTAP_BURST_PDU                 0x04 
	#define WMXTAP_BURST_HACK                0x05
	#define WMXTAP_BURST_PHY_ATTRIBUTES      0x06   

	#define WMXTAP_UDP_PORT                  4779 
 	 
 	/* This is the header as it is used by wmxtap-generating software. 
 	 * It is not used by the wireshark dissector and provided for reference only. 
 	struct wmxtap_hdr { 
	        guint8 version;         // version, set to 0x01 currently 
	        guint8 hdr_len;         // length in number of 32bit words 
	        guint8 type;            // see WMXTAP_TYPE_* 
	        guint8 sub_type;        // Type of burst 
	} 
	*/ 
	 
#endif /* _WMXTAP_H */ 
