import 'package:flutter/material.dart';

class PlayableCharacter {
  final String name;
  final String assetFolder;
  final String previewAsset;

  const PlayableCharacter({
    required this.name,
    required this.assetFolder,
    required this.previewAsset,
  });
}

const List<PlayableCharacter> playableCharacters = [
  PlayableCharacter(
    name: 'Pink Monster',
    assetFolder: 'assets/images/player/craftpix-net-622999-free-pixel-art-tiny-hero-sprites/1 Pink_Monster/',
    previewAsset: 'assets/images/player/craftpix-net-622999-free-pixel-art-tiny-hero-sprites/1 Pink_Monster/Pink_Monster.png',
  ),
  PlayableCharacter(
    name: 'Owlet Monster',
    assetFolder: 'assets/images/player/craftpix-net-622999-free-pixel-art-tiny-hero-sprites/2 Owlet_Monster/',
    previewAsset: 'assets/images/player/craftpix-net-622999-free-pixel-art-tiny-hero-sprites/2 Owlet_Monster/Owlet_Monster.png',
  ),
  PlayableCharacter(
    name: 'Dude Monster',
    assetFolder: 'assets/images/player/craftpix-net-622999-free-pixel-art-tiny-hero-sprites/3 Dude_Monster/',
    previewAsset: 'assets/images/player/craftpix-net-622999-free-pixel-art-tiny-hero-sprites/3 Dude_Monster/Dude_Monster.png',
  ),
];
