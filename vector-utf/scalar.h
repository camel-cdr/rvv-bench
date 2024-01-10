// code from https://github.com/simdutf/simdutf/tree/master/src/scalar

// little endian
size_t
utf8_to_utf16_scalar(const char *buf, size_t len, uint16_t *utf16_output)
{
	const uint8_t *data = (const uint8_t *)buf;
	size_t pos = 0;
	uint16_t *start = utf16_output;
	while (pos < len) {
		// try to convert the next block of 16 ASCII bytes
		if (pos + 16 <= len) { // if it is safe to read 16 more bytes, check that they are ascii
			uint64_t v1;
			memcpy(&v1, data + pos, sizeof(uint64_t));
			uint64_t v2;
			memcpy(&v2, data + pos + sizeof(uint64_t), sizeof(uint64_t));
			uint64_t v = v1 | v2;
			if ((v & 0x8080808080808080) == 0) {
				size_t final_pos = pos + 16;
				while(pos < final_pos) {
					*utf16_output++ = (uint16_t)(buf[pos]);
					pos++;
				}
				continue;
			}
		}

		uint8_t leading_byte = data[pos]; // leading byte
		if (leading_byte < 0b10000000) {
			// converting one ASCII byte !!!
			*utf16_output++ = (uint16_t)leading_byte;
			pos++;
		} else if ((leading_byte & 0b11100000) == 0b11000000) {
			// We have a two-byte UTF-8, it should become
			// a single UTF-16 word.
			if(pos + 1 >= len) { return 0; } // minimal bound checking
			if ((data[pos + 1] & 0b11000000) != 0b10000000) { return 0; }
			// range check
			uint32_t code_point = (leading_byte & 0b00011111) << 6 | (data[pos + 1] & 0b00111111);
			if (code_point < 0x80 || 0x7ff < code_point) { return 0; }
			*utf16_output++ = (uint16_t)code_point;
			pos += 2;
		} else if ((leading_byte & 0b11110000) == 0b11100000) {
			// We have a three-byte UTF-8, it should become
			// a single UTF-16 word.
			if(pos + 2 >= len) { return 0; } // minimal bound checking

			if ((data[pos + 1] & 0b11000000) != 0b10000000) { return 0; }
			if ((data[pos + 2] & 0b11000000) != 0b10000000) { return 0; }
			// range check
			uint32_t code_point = (leading_byte & 0b00001111) << 12 |
				(data[pos + 1] & 0b00111111) << 6 |
				(data[pos + 2] & 0b00111111);
			if (code_point < 0x800 || 0xffff < code_point ||
					(0xd7ff < code_point && code_point < 0xe000)) {
				return 0;
			}
			*utf16_output++ = (uint16_t)code_point;
			pos += 3;
		} else if ((leading_byte & 0b11111000) == 0b11110000) { // 0b11110000
									// we have a 4-byte UTF-8 word.
			if(pos + 3 >= len) { return 0; } // minimal bound checking
			if ((data[pos + 1] & 0b11000000) != 0b10000000) { return 0; }
			if ((data[pos + 2] & 0b11000000) != 0b10000000) { return 0; }
			if ((data[pos + 3] & 0b11000000) != 0b10000000) { return 0; }

			// range check
			uint32_t code_point =
				(leading_byte & 0b00000111) << 18 | (data[pos + 1] & 0b00111111) << 12 |
				(data[pos + 2] & 0b00111111) << 6 | (data[pos + 3] & 0b00111111);
			if (code_point <= 0xffff || 0x10ffff < code_point) { return 0; }
			code_point -= 0x10000;
			uint16_t high_surrogate = (uint16_t)(0xD800 + (code_point >> 10));
			uint16_t low_surrogate = (uint16_t)(0xDC00 + (code_point & 0x3FF));
			*utf16_output++ = (uint16_t)(high_surrogate);
			*utf16_output++ = (uint16_t)(low_surrogate);
			pos += 4;
		} else {
			return 0;
		}
	}
	return utf16_output - start;
}

size_t
utf8_to_utf32_scalar(const char *buf, size_t len, uint32_t *utf32_output)
{
	const uint8_t *data = (const uint8_t *)buf;
	size_t pos = 0;
	uint32_t* start = utf32_output;
	while (pos < len) {
		// try to convert the next block of 16 ASCII bytes
		if (pos + 16 <= len) { // if it is safe to read 16 more bytes, check that they are ascii
			uint64_t v1;
			memcpy(&v1, data + pos, sizeof(uint64_t));
			uint64_t v2;
			memcpy(&v2, data + pos + sizeof(uint64_t), sizeof(uint64_t));
			uint64_t v = v1 | v2;
			if ((v & 0x8080808080808080) == 0) {
				size_t final_pos = pos + 16;
				while(pos < final_pos) {
					*utf32_output++ = (uint32_t)buf[pos];
					pos++;
				}
				continue;
			}
		}
		uint8_t leading_byte = data[pos]; // leading byte
		if (leading_byte < 0b10000000) {
			// converting one ASCII byte !!!
			*utf32_output++ = (uint32_t)leading_byte;
			pos++;
		} else if ((leading_byte & 0b11100000) == 0b11000000) {
			// We have a two-byte UTF-8
			if(pos + 1 >= len) { return 0; } // minimal bound checking
			if ((data[pos + 1] & 0b11000000) != 0b10000000) { return 0; }
			// range check
			uint32_t code_point = (leading_byte & 0b00011111) << 6 | (data[pos + 1] & 0b00111111);
			if (code_point < 0x80 || 0x7ff < code_point) { return 0; }
			*utf32_output++ = (uint32_t)code_point;
			pos += 2;
		} else if ((leading_byte & 0b11110000) == 0b11100000) {
			// We have a three-byte UTF-8
			if (pos + 2 >= len) { return 0; } // minimal bound checking

			if ((data[pos + 1] & 0b11000000) != 0b10000000) { return 0; }
			if ((data[pos + 2] & 0b11000000) != 0b10000000) { return 0; }
			// range check
			uint32_t code_point = (leading_byte & 0b00001111) << 12 |
				(data[pos + 1] & 0b00111111) << 6 |
				(data[pos + 2] & 0b00111111);
			if (code_point < 0x800 || 0xffff < code_point ||
					(0xd7ff < code_point && code_point < 0xe000)) {
				return 0;
			}
			*utf32_output++ = (uint32_t)code_point;
			pos += 3;
		} else if ((leading_byte & 0b11111000) == 0b11110000) { // 0b11110000
									// we have a 4-byte UTF-8 word.
			if(pos + 3 >= len) { return 0; } // minimal bound checking
			if ((data[pos + 1] & 0b11000000) != 0b10000000) { return 0; }
			if ((data[pos + 2] & 0b11000000) != 0b10000000) { return 0; }
			if ((data[pos + 3] & 0b11000000) != 0b10000000) { return 0; }

			// range check
			uint32_t code_point =
				(leading_byte & 0b00000111) << 18 | (data[pos + 1] & 0b00111111) << 12 |
				(data[pos + 2] & 0b00111111) << 6 | (data[pos + 3] & 0b00111111);
			if (code_point <= 0xffff || 0x10ffff < code_point) { return 0; }
			*utf32_output++ = (uint32_t)code_point;
			pos += 4;
		} else {
			return 0;
		}
	}
	return utf32_output - start;
}


// little endian
size_t
utf16_to_utf8_scalar(const uint16_t *buf, size_t len, char *utf8_output)
{
	const uint16_t *data = (const uint16_t *)buf;
	size_t pos = 0;
	char *start = utf8_output;
	while (pos < len) {
		// try to convert the next block of 8 bytes
		if (pos + 4 <= len) { // if it is safe to read 8 more bytes, check that they are ascii
			uint64_t v;
			memcpy(&v, data + pos, sizeof(uint64_t));
			if ((v & 0xFF80FF80FF80FF80) == 0) {
				size_t final_pos = pos + 4;
				while(pos < final_pos) {
					*utf8_output++ =  (char)(buf[pos]);
					pos++;
				}
				continue;
			}
		}
		uint16_t word = data[pos];
		if((word & 0xFF80)==0) {
			// will generate one UTF-8 bytes
			*utf8_output++ = (char)(word);
			pos++;
		} else if((word & 0xF800)==0) {
			// will generate two UTF-8 bytes
			// we have 0b110XXXXX 0b10XXXXXX
			*utf8_output++ = (char)((word>>6) | 0b11000000);
			*utf8_output++ = (char)((word & 0b111111) | 0b10000000);
			pos++;
		} else if((word &0xF800 ) != 0xD800) {
			// will generate three UTF-8 bytes
			// we have 0b1110XXXX 0b10XXXXXX 0b10XXXXXX
			*utf8_output++ = (char)((word>>12) | 0b11100000);
			*utf8_output++ = (char)(((word>>6) & 0b111111) | 0b10000000);
			*utf8_output++ = (char)((word & 0b111111) | 0b10000000);
			pos++;
		} else {
			// must be a surrogate pair
			if(pos + 1 >= len) { return 0; }
			uint16_t diff = (uint16_t)(word - 0xD800);
			if(diff > 0x3FF) { return 0; }
			uint16_t next_word = data[pos + 1];
			uint16_t diff2 = (uint16_t)(next_word - 0xDC00);
			if(diff2 > 0x3FF) { return 0; }
			uint32_t value = (diff << 10) + diff2 + 0x10000;
			// will generate four UTF-8 bytes
			// we have 0b11110XXX 0b10XXXXXX 0b10XXXXXX 0b10XXXXXX
			*utf8_output++ = (char)((value>>18) | 0b11110000);
			*utf8_output++ = (char)(((value>>12) & 0b111111) | 0b10000000);
			*utf8_output++ = (char)(((value>>6) & 0b111111) | 0b10000000);
			*utf8_output++ = (char)((value & 0b111111) | 0b10000000);
			pos += 2;
		}
	}
	return utf8_output - start;
}


size_t
utf32_to_utf8_scalar(const uint32_t *buf, size_t len, char *utf8_output)
{
	const uint32_t *data = (const uint32_t *)buf;
	size_t pos = 0;
	char *start = utf8_output;
	while (pos < len) {
		// try to convert the next block of 2 ASCII characters
		if (pos + 2 <= len) { // if it is safe to read 8 more bytes, check that they are ascii
			uint64_t v;
			memcpy(&v, data + pos, sizeof(uint64_t));
			if ((v & 0xFFFFFF80FFFFFF80) == 0) {
				*utf8_output++ = (char)(buf[pos]);
				*utf8_output++ = (char)(buf[pos+1]);
				pos += 2;
				continue;
			}
		}
		uint32_t word = data[pos];
		if((word & 0xFFFFFF80)==0) {
			// will generate one UTF-8 bytes
			*utf8_output++ = (char)(word);
			pos++;
		} else if((word & 0xFFFFF800)==0) {
			// will generate two UTF-8 bytes
			// we have 0b110XXXXX 0b10XXXXXX
			*utf8_output++ = (char)((word>>6) | 0b11000000);
			*utf8_output++ = (char)((word & 0b111111) | 0b10000000);
			pos++;
		} else if((word & 0xFFFF0000)==0) {
			// will generate three UTF-8 bytes
			// we have 0b1110XXXX 0b10XXXXXX 0b10XXXXXX
			if (word >= 0xD800 && word <= 0xDFFF) { return 0; }
			*utf8_output++ = (char)((word>>12) | 0b11100000);
			*utf8_output++ = (char)(((word>>6) & 0b111111) | 0b10000000);
			*utf8_output++ = (char)((word & 0b111111) | 0b10000000);
			pos++;
		} else {
			// will generate four UTF-8 bytes
			// we have 0b11110XXX 0b10XXXXXX 0b10XXXXXX 0b10XXXXXX
			if (word > 0x10FFFF) { return 0; }
			*utf8_output++ = (char)((word>>18) | 0b11110000);
			*utf8_output++ = (char)(((word>>12) & 0b111111) | 0b10000000);
			*utf8_output++ = (char)(((word>>6) & 0b111111) | 0b10000000);
			*utf8_output++ = (char)((word & 0b111111) | 0b10000000);
			pos ++;
		}
	}
	return utf8_output - start;
}

// little endian
size_t
utf32_to_utf16_scalar(const uint32_t *buf, size_t len, uint16_t *utf16_output)
{
	const uint32_t *data = (const uint32_t*)buf;
	size_t pos = 0;
	uint16_t *start = utf16_output;
	while (pos < len) {
		uint32_t word = data[pos];
		if((word & 0xFFFF0000)==0) {
			if (word >= 0xD800 && word <= 0xDFFF) { return 0; }
			// will not generate a surrogate pair
			*utf16_output++ = word;
		} else {
			// will generate a surrogate pair
			if (word > 0x10FFFF) { return 0; }
			word -= 0x10000;
			uint16_t high_surrogate = 0xD800 + (word >> 10);
			uint16_t low_surrogate = 0xDC00 + (word & 0x3FF);
			*utf16_output++ = high_surrogate;
			*utf16_output++ = low_surrogate;
		}
		pos++;
	}
	return utf16_output - start;
}
