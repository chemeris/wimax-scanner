/* packet-wmxtap.c 
 * Routines for WMXTAP captures 
*/
/* WMXTAP is a generic header format for WiMax protocol captures, 
 * it uses UDP port number 4779 and carries 
 * payload in various formats of WiMax interfaces. 
 */ 
	 
#ifdef HAVE_CONFIG_H 
# include "config.h" 
#endif 
 
#include <glib.h> 
#include <epan/packet.h> 
#include <epan/prefs.h> 
	 
#include "packet-wmxtap.h" 
  
static int proto_wmxtap = -1; 
static int hf_wmxtap_version = -1; 
static int hf_wmxtap_hdrlen = -1; 
static int hf_wmxtap_type = -1; 
static int hf_wmxtap_burst_type = -1; 
	 
static gint ett_wmxtap = -1; 
 	 
enum { 
	WMXTAP_SUB_DATA = 0,
        WMXTAP_SUB_CDMA_CODE, 
	WMXTAP_SUB_FCH,
	WMXTAP_SUB_FFB,
	WMXTAP_SUB_PDU,
	WMXTAP_SUB_HACK,
	WMXTAP_SUB_PHY_ATTRIBUTES,
        WMXTAP_SUB_MAX 
}; 
 
static dissector_handle_t sub_handles[WMXTAP_SUB_MAX]; 

static const value_string wmxtap_bursts[] = { 
	{ WMXTAP_BURST_UNKNOWN,             "UNKNOWN"  },
 	{ WMXTAP_BURST_CDMA_CODE,           "CDMA Code"  },
	{ WMXTAP_BURST_FCH,                 "FCH"  },
	{ WMXTAP_BURST_FFB,                 "Fast Feedback" },
	{ WMXTAP_BURST_PDU,                 "PDU" },
	{ WMXTAP_BURST_HACK,                "HACK" },
	{ WMXTAP_BURST_PHY_ATTRIBUTES,      "PHY Attributes" },
        { 0,                                NULL }, 
}; 

static const value_string wmxtap_types[] = { 
        { WMXTAP_TYPE_BURST, "WiMax burst (MS<->BTS)" }, 
        { 0,                     NULL }, 
}; 


/* dissect a WMXTAP header and hand payload off to respective dissector */ 
static void 
dissect_wmxtap(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree) 
{ 
        int sub_handle, len, offset = 0; 
        proto_item *ti; 
        proto_tree *wmxtap_tree = NULL; 
        tvbuff_t *payload_tvb, *l1h_tvb = NULL; 
        guint8 hdr_len, type, sub_type; 

        len = tvb_length(tvb); 
	 
        hdr_len = tvb_get_guint8(tvb, offset + 1) <<2; 
        type = tvb_get_guint8(tvb, offset + 2); 
        sub_type = tvb_get_guint8(tvb, offset + 3); 
 
        payload_tvb = tvb_new_subset(tvb, hdr_len, len-hdr_len, len-hdr_len); 

        col_clear(pinfo->cinfo, COL_INFO); 
 
        col_set_str(pinfo->cinfo, COL_PROTOCOL, "WMXTAP"); 

        col_append_str(pinfo->cinfo, COL_RES_NET_SRC, "MS"); 

        col_append_str(pinfo->cinfo, COL_RES_NET_DST, "BTS"); 

        pinfo->p2p_dir = P2P_DIR_RECV; 
 
        if (tree) { 
                ti = proto_tree_add_protocol_format(tree, proto_wmxtap, tvb, 0, hdr_len, "WiMax TAP Header"); 
                wmxtap_tree = proto_item_add_subtree(ti, ett_wmxtap); 
                proto_tree_add_item(wmxtap_tree, hf_wmxtap_version, tvb, offset, 1, FALSE); 
	        proto_tree_add_uint_format(wmxtap_tree, hf_wmxtap_hdrlen, tvb, offset+1, 1, hdr_len, "Header length: %u bytes", hdr_len); 
                proto_tree_add_item(wmxtap_tree, hf_wmxtap_type, tvb, offset+2, 1, FALSE); 
                proto_tree_add_item(wmxtap_tree, hf_wmxtap_burst_type, tvb, offset+3, 1, FALSE); 
        } 


        switch (sub_type) { 
	        case WMXTAP_BURST_CDMA_CODE: 
			sub_handle = WMXTAP_SUB_CDMA_CODE;
			break;
	        case WMXTAP_BURST_FCH: 
			sub_handle = WMXTAP_SUB_FCH;
			break;
	        case WMXTAP_BURST_FFB: 
			sub_handle = WMXTAP_SUB_FFB;
			break;
	        case WMXTAP_BURST_PDU: 
			sub_handle = WMXTAP_SUB_PDU;
			break;
	        case WMXTAP_BURST_HACK: 
			sub_handle = WMXTAP_SUB_HACK;
			break;
	        case WMXTAP_BURST_PHY_ATTRIBUTES: 
			sub_handle = WMXTAP_SUB_PHY_ATTRIBUTES;
			break;
	        default: 
	                sub_handle = WMXTAP_SUB_DATA; 
	                break; 
	        } 

        call_dissector(sub_handles[sub_handle], payload_tvb, pinfo, tree); 
} 

void 
proto_register_wmxtap(void) 
{ 
        static hf_register_info hf[] = { 
                { &hf_wmxtap_version, { "Version", "wmxtap.version", 
                  FT_UINT8, BASE_DEC, NULL, 0, NULL, HFILL } }, 
                { &hf_wmxtap_hdrlen, { "Header Length", "wmxtap.hdr_len", 
                  FT_UINT8, BASE_DEC, NULL, 0, NULL, HFILL } }, 
                { &hf_wmxtap_type, { "Payload Type", "wmxtap.type", 
                  FT_UINT8, BASE_DEC, VALS(wmxtap_types), 0, NULL, HFILL } }, 
                { &hf_wmxtap_burst_type, { "Burst Type", "wmxtap.burst_type", 
                  FT_UINT8, BASE_DEC, VALS(wmxtap_bursts), 0, NULL, HFILL }}, 
        }; 

        static gint *ett[] = { 
                &ett_wmxtap 
        }; 
	 
        proto_wmxtap = proto_register_protocol("WiMax Radiotap", "WMXTAP", "wmxtap"); 
        proto_register_field_array(proto_wmxtap, hf, array_length(hf)); 
        proto_register_subtree_array(ett, array_length(ett)); 
} 
	 
void 
proto_reg_handoff_wmxtap(void) 
{ 
        dissector_handle_t wmxtap_handle; 
	sub_handles[WMXTAP_SUB_DATA] = find_dissector("data"); 
        sub_handles[WMXTAP_SUB_CDMA_CODE] = find_dissector("wimax_cdma_code_burst_handler"); 
        sub_handles[WMXTAP_SUB_FCH] = find_dissector("wimax_fch_burst_handler"); 
        sub_handles[WMXTAP_SUB_FFB] = find_dissector("wimax_ffb_burst_handler"); 
        sub_handles[WMXTAP_SUB_PDU] = find_dissector("wimax_pdu_burst_handler");
        sub_handles[WMXTAP_SUB_HACK] = find_dissector("wimax_hack_burst_handler");
        sub_handles[WMXTAP_SUB_PHY_ATTRIBUTES] = find_dissector("wimax_phy_attributes_burst_handler");
        wmxtap_handle = create_dissector_handle(dissect_wmxtap, proto_wmxtap); 
        dissector_add("udp.port", WMXTAP_UDP_PORT, wmxtap_handle); 
} 
