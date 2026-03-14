# frozen_string_literal: true

module Legion
  module Extensions
    module Metacognition
      module Helpers
        module Constants
          # Maximum cached self-model snapshots
          MAX_SNAPSHOTS = 50

          # How long a self-model snapshot is considered fresh (seconds)
          SNAPSHOT_TTL = 30

          # Subsystems the self-model introspects
          SUBSYSTEMS = %i[
            tick cortex memory emotion prediction identity
            curiosity attention reflection volition language
            trust consent coldstart mesh dream
            narrator metacognition homeostasis empathy
            imagination mood salience habit temporal
            fatigue personality flow reward
            conscience resilience social creativity
            theory_of_mind planning inhibition schema
            working_memory motivation agency surprise
            priming dissonance gestalt bias
            arousal context anchoring
            narrative_self cognitive_load
            learning_rate emotional_regulation
            mentalizing prospection
            interoception mirror joint_attention
            semantic_memory default_mode_network
            predictive_coding attention_schema
            global_workspace hebbian_assembly
            cognitive_map error_monitoring
            neuromodulation feature_binding
            executive_function neural_oscillation
            source_monitoring somatic_marker
            affordance episodic_buffer
            cognitive_flexibility embodied_simulation
            predictive_processing belief_revision
            mental_time_travel cognitive_control
            perceptual_inference inner_speech
            self_model cognitive_rhythm
            cognitive_empathy attention_regulation
            intuition free_energy
            counterfactual moral_reasoning
            analogical_reasoning causal_reasoning
            cognitive_reserve appraisal
            cognitive_coherence conceptual_blending
            dual_process abductive_reasoning
            social_learning conceptual_metaphor
            procedural_learning signal_detection
            bayesian_belief cognitive_scaffolding
            enactive_cognition distributed_cognition
            cognitive_entrainment narrative_reasoning
            causal_attribution cognitive_apprenticeship
            pragmatic_inference
            cognitive_momentum relevance_theory
            situation_model cognitive_disengagement
            epistemic_vigilance frame_semantics
            expectation_violation
            argument_mapping mental_simulation
            cognitive_grammar cognitive_architecture
            cognitive_fatigue_model uncertainty_tolerance
            preference_learning
            temporal_discounting cognitive_immunology
            phenomenal_binding meta_learning
            cognitive_homeostasis attentional_blink
            cognitive_contagion prospective_memory
            cognitive_dissonance_resolution attention_economy
            cognitive_load_balancing semantic_satiation
            cognitive_debt reality_testing cognitive_friction
            epistemic_curiosity cognitive_boundary decision_fatigue
            cognitive_resonance latent_inhibition cognitive_surplus
            transfer_learning cognitive_compression cognitive_plasticity
            anosognosia confabulation cognitive_tempo
            hypothesis_testing cognitive_inertia sensory_gating
            cognitive_synthesis metacognitive_monitoring
            cognitive_defusion cognitive_reappraisal
            semantic_priming cognitive_integration
          ].freeze

          # Capability categories for self-description
          CAPABILITY_CATEGORIES = %i[
            perception cognition memory motivation safety
            communication introspection coordination
          ].freeze

          # Maps extensions to capability categories
          EXTENSION_CAPABILITIES = {
            Tick:                          :cognition,
            Cortex:                        :cognition,
            Memory:                        :memory,
            Emotion:                       :perception,
            Prediction:                    :cognition,
            Identity:                      :safety,
            Curiosity:                     :motivation,
            Attention:                     :perception,
            Reflection:                    :introspection,
            Volition:                      :motivation,
            Language:                      :introspection,
            Trust:                         :safety,
            Consent:                       :safety,
            Coldstart:                     :cognition,
            Mesh:                          :communication,
            Dream:                         :cognition,
            Narrator:                      :introspection,
            Metacognition:                 :introspection,
            Conflict:                      :safety,
            Governance:                    :safety,
            Extinction:                    :safety,
            Privatecore:                   :safety,
            Swarm:                         :coordination,
            SwarmGithub:                   :coordination,
            Homeostasis:                   :cognition,
            Empathy:                       :communication,
            Imagination:                   :cognition,
            Mood:                          :perception,
            Salience:                      :perception,
            Habit:                         :cognition,
            Temporal:                      :perception,
            Fatigue:                       :cognition,
            Personality:                   :introspection,
            Flow:                          :cognition,
            Reward:                        :motivation,
            Conscience:                    :safety,
            Resilience:                    :cognition,
            Social:                        :communication,
            Creativity:                    :cognition,
            TheoryOfMind:                  :communication,
            Planning:                      :cognition,
            Inhibition:                    :safety,
            Schema:                        :cognition,
            WorkingMemory:                 :memory,
            Motivation:                    :motivation,
            Agency:                        :motivation,
            Surprise:                      :perception,
            Priming:                       :cognition,
            Dissonance:                    :cognition,
            Gestalt:                       :perception,
            Bias:                          :introspection,
            Arousal:                       :cognition,
            Context:                       :cognition,
            Anchoring:                     :cognition,
            NarrativeSelf:                 :introspection,
            CognitiveLoad:                 :cognition,
            LearningRate:                  :cognition,
            EmotionalRegulation:           :introspection,
            Mentalizing:                   :communication,
            Prospection:                   :cognition,
            Interoception:                 :perception,
            Mirror:                        :communication,
            JointAttention:                :communication,
            SemanticMemory:                :memory,
            DefaultModeNetwork:            :cognition,
            PredictiveCoding:              :cognition,
            AttentionSchema:               :introspection,
            GlobalWorkspace:               :cognition,
            HebbianAssembly:               :cognition,
            CognitiveMap:                  :cognition,
            ErrorMonitoring:               :safety,
            Neuromodulation:               :cognition,
            FeatureBinding:                :perception,
            ExecutiveFunction:             :cognition,
            NeuralOscillation:             :cognition,
            SourceMonitoring:              :introspection,
            SomaticMarker:                 :perception,
            Affordance:                    :perception,
            EpisodicBuffer:                :memory,
            CognitiveFlexibility:          :cognition,
            EmbodiedSimulation:            :cognition,
            PredictiveProcessing:          :cognition,
            BeliefRevision:                :cognition,
            MentalTimeTravel:              :cognition,
            CognitiveControl:              :cognition,
            PerceptualInference:           :perception,
            InnerSpeech:                   :introspection,
            SelfModel:                     :introspection,
            CognitiveRhythm:               :cognition,
            CognitiveEmpathy:              :communication,
            AttentionRegulation:           :perception,
            Intuition:                     :cognition,
            FreeEnergy:                    :cognition,
            Counterfactual:                :cognition,
            MoralReasoning:                :safety,
            AnalogicalReasoning:           :cognition,
            CausalReasoning:               :cognition,
            CognitiveReserve:              :cognition,
            Appraisal:                     :cognition,
            CognitiveCoherence:            :cognition,
            ConceptualBlending:            :cognition,
            DualProcess:                   :cognition,
            AbductiveReasoning:            :cognition,
            SocialLearning:                :communication,
            ConceptualMetaphor:            :cognition,
            ProceduralLearning:            :cognition,
            SignalDetection:               :perception,
            BayesianBelief:                :cognition,
            CognitiveScaffolding:          :cognition,
            EnactiveCognition:             :cognition,
            DistributedCognition:          :coordination,
            CognitiveEntrainment:          :coordination,
            NarrativeReasoning:            :cognition,
            CausalAttribution:             :cognition,
            CognitiveApprenticeship:       :cognition,
            PragmaticInference:            :communication,
            CognitiveMomentum:             :cognition,
            RelevanceTheory:               :cognition,
            SituationModel:                :cognition,
            CognitiveDisengagement:        :cognition,
            EpistemicVigilance:            :safety,
            FrameSemantics:                :cognition,
            ExpectationViolation:          :perception,
            ArgumentMapping:               :cognition,
            MentalSimulation:              :cognition,
            CognitiveGrammar:              :cognition,
            CognitiveArchitecture:         :introspection,
            CognitiveFatigueModel:         :cognition,
            UncertaintyTolerance:          :cognition,
            PreferenceLearning:            :cognition,
            TemporalDiscounting:           :cognition,
            CognitiveImmunology:           :safety,
            PhenomenalBinding:             :perception,
            MetaLearning:                  :cognition,
            CognitiveHomeostasis:          :cognition,
            AttentionalBlink:              :perception,
            CognitiveContagion:            :communication,
            ProspectiveMemory:             :memory,
            CognitiveDissonanceResolution: :cognition,
            AttentionEconomy:              :cognition,
            CognitiveLoadBalancing:        :cognition,
            SemanticSatiation:             :perception,
            CognitiveDebt:                 :cognition,
            RealityTesting:                :cognition,
            CognitiveFriction:             :cognition,
            EpistemicCuriosity:            :motivation,
            CognitiveBoundary:             :safety,
            DecisionFatigue:               :cognition,
            CognitiveResonance:            :perception,
            LatentInhibition:              :cognition,
            CognitiveSurplus:              :cognition,
            TransferLearning:              :cognition,
            CognitiveCompression:          :memory,
            CognitivePlasticity:           :cognition,
            Anosognosia:                   :safety,
            Confabulation:                 :safety,
            CognitiveTempo:                :cognition,
            HypothesisTesting:             :cognition,
            CognitiveInertia:              :cognition,
            SensoryGating:                 :perception,
            CognitiveSynthesis:            :cognition,
            MetacognitiveMonitoring:       :introspection,
            CognitiveDefusion:             :introspection,
            CognitiveReappraisal:          :introspection,
            SemanticPriming:               :cognition,
            CognitiveIntegration:          :cognition
          }.freeze

          # Subsystem health labels
          HEALTH_LABELS = {
            (0.8..)     => :excellent,
            (0.6...0.8) => :good,
            (0.4...0.6) => :fair,
            (0.2...0.4) => :degraded,
            (..0.2)     => :critical
          }.freeze
        end
      end
    end
  end
end
