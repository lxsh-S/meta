const std = @import("std");

pub const MediaType = enum {
    image,
    video,
    other,
};

pub fn detectMediaType(header: []const u8) MediaType {
    // png
    if (std.mem.startsWith(u8, header, "\x89PNG\r\n\x1a\n")) return .image;

    // jpeg
    if (std.mem.startsWith(u8, header, "\xff\xd8\xff")) return .image;

    // gif
    if (std.mem.startsWith(u8, header, "GIF87a") or std.mem.startsWith(u8, header, "GIF89a")) return .image;

    // webp
    if (header.len >= 12 and std.mem.startsWith(u8, header, "RIFF") and std.mem.eql(u8, header[8..12], "WEBP")) return .image;

    //bmp
    if (std.mem.startsWith(u8, header, "BM")) return .image;

    // mpv / mov / m4v
    if (header.len >= 8 and std.mem.eql(u8, header[4..8], "ftyp")) return .video;

    // mkv / webm
    if (std.mem.startsWith(u8, header, "\x1a\x45\xdf\xa3")) return .video;

    // avi
    if (header.len >= 12 and std.mem.startsWith(u8, header, "RIFF") and std.mem.eql(u8, header[8..12], "AVI ")) return .video;

    // flv
    if (std.mem.startsWith(u8, header, "FLV\x01")) return .video;

    return .other;
}
