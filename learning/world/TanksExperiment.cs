using SharpNeat.Core;
using SharpNeat.Phenomes;
using System;
using System.Collections.Generic;
using System.Text;

namespace world
{
    public class TanksExperiment : SimpleNeatExperiment
    {
        public override IPhenomeEvaluator<IBlackBox> PhenomeEvaluator => new TanksEvaluator();
        public override int InputCount => 6 + 10 * tanks.Globals.MaxBullets;
        public override int OutputCount => 12;
        public override bool EvaluateParents => true;
    }
}
