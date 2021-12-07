package jackboxgames.jobgame.utils
{
    import jackboxgames.utils.*;

    import jackboxgames.jobgame.*;
    import jackboxgames.jobgame.model.*;

    public class StashManager
    {
        private static var _instance:StashManager;
        public static function get instance():StashManager
        {
            if (!_instance)
            {
                _instance = new StashManager();
            }
            return _instance;
        }

        private var _phrases:Array;

        private var _shuffledPlayers:Array;
        private var _lookup:Array;

        public function StashManager()
        {
        }

        public function setupForNewGame(players:Array):void
        {
            _shuffledPlayers = ArrayUtil.shuffled(players);
            _lookup = DivvyTable.TABLE_BY_PLAYER_COUNT[players.length];

            _phrases = [];
            for each (var p:Player in _shuffledPlayers)
            {
                _phrases.push([]);
            }
        }

        public function addPhrases(author:Player, phrases:Array):void
        {
            var index:int = _shuffledPlayers.indexOf(author);
            _phrases[index] = _phrases[index].concat(phrases);
        }

        private function _divvy(start:int, end:int, round:String):void
        {
            for (var i:int = 0; i < _shuffledPlayers.length; i++)
            {
                for (var j:int = start; j < end; j++)
                {
                    _shuffledPlayers[i].addPhrase(_phrases[_lookup[i][j][0]][_lookup[i][j][1]], round);
                }
            }
        }

        public function divvyRoundOneWords():void
        {
            _divvy(0, 3, GameConstants.ROUND_ONE);
        }

        public function divvyRoundTwoWords():void
        {
            _divvy(3, 6, GameConstants.ROUND_TWO);
        }

        public function divvyRoundThreeWords():void
        {
            _divvy(6, 9, GameConstants.ROUND_THREE);
        }
    }
}
