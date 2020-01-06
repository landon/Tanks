using System;
using System.Collections.Generic;
using System.Text;

using SharpNeat.Core;
using SharpNeat.Phenomes;

namespace world
{
    public class NeatAgent : Agent
    {
        IBlackBox _brain;
        public NeatAgent(IBlackBox brain)
        {
            _brain = brain;
        }

        public override (bool up, bool down, bool left, bool right, bool go, bool fire) React(int x, int y, int angle, int ox, int oy, int oangle, List<tanks.Bullet> bullets)
        {
            _brain.ResetState();
            _brain.InputSignalArray[0] = x;
            _brain.InputSignalArray[1] = y;
            _brain.InputSignalArray[2] = angle;
            _brain.InputSignalArray[3] = ox;
            _brain.InputSignalArray[4] = oy;
            _brain.InputSignalArray[5] = oangle;
            
            for (int i = 0; i < 2 * tanks.Globals.MaxBullets; i++)
            {
                if (i < bullets.Count)
                {
                    _brain.InputSignalArray[6 + i * 5] = bullets[i].Age;
                    _brain.InputSignalArray[6 + i * 5 + 1] = bullets[i].X;
                    _brain.InputSignalArray[6 + i * 5 + 2] = bullets[i].Y;
                    _brain.InputSignalArray[6 + i * 5 + 3] = bullets[i].DX;
                    _brain.InputSignalArray[6 + i * 5 + 4] = bullets[i].DY;
                }
                else
                {
                    _brain.InputSignalArray[6 + i * 5] = 0;
                    _brain.InputSignalArray[6 + i * 5 + 1] = 0;
                    _brain.InputSignalArray[6 + i * 5 + 2] = 0;
                    _brain.InputSignalArray[6 + i * 5 + 3] = 0;
                    _brain.InputSignalArray[6 + i * 5 + 4] = 0;
                }
            }

            _brain.Activate();
            return (_brain.OutputSignalArray[0] > _brain.OutputSignalArray[1],
                    _brain.OutputSignalArray[2] > _brain.OutputSignalArray[3],
                    _brain.OutputSignalArray[4] > _brain.OutputSignalArray[5],
                    _brain.OutputSignalArray[6] > _brain.OutputSignalArray[7],
                    _brain.OutputSignalArray[8] > _brain.OutputSignalArray[9],
                    _brain.OutputSignalArray[10] > _brain.OutputSignalArray[11]);
        }
    }

    public class TanksEvaluator : IPhenomeEvaluator<IBlackBox>
    {
        public ulong EvaluationCount { get; private set; }
        public bool StopConditionSatisfied => false;

        public FitnessInfo Evaluate(IBlackBox brain)
        {
            EvaluationCount++;
            var fitness = 0;
            var random = new StationaryAgent();
            var neat = new NeatAgent(brain);

            for (int i = 0; i < 2; i++)
            {
                var result = GameLoop.RunGame(neat, random);
                fitness += result > 0 ? 10 : 0;
            }

            return new FitnessInfo(fitness, fitness);
        }

        public void Reset()
        {
        }
    }
}
